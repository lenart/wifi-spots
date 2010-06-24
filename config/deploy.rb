# set :mongrel_conf, "#{deploy_to}/current/config/mongrel_cluster.yml"

## OLD
set :user, "wifitocke"
set :domain, "#{user}@s3.ruby.si"
set :ssh_flags, "-p 65022"
set :application, "wifi-tocke.si"
set :deploy_to, "/home/wifitocke/#{application}"
set :repository, "git@github.com:lenart/wifi-spots.git"

set :mongrel_conf, "#{deploy_to}/current/config/mongrel_cluster.yml"
set :mongrel_environment, 'production'

#
# Mongrel configuration
#
# set :mongrel_clean,         true
# set :mongrel_command,       'mongrel_rails'
# set :mongrel_group,         'www-data'
# set :mongrel_port,          9000
# set :mongrel_servers,       3
# set :mongrel_address,       '127.0.0.1'
# set(:mongrel_conf)          { '#{shared_path}/mongrel_cluster.conf' }
# set :mongrel_config_script, nil
# set :mongrel_environment,   'production'
# set :mongrel_log_file,      nil
# set :mongrel_pid_file,      nil
# set :mongrel_prefix,        nil
# set :mongrel_user,          'mongrel'

namespace :vlad do

  remote_task :start, :roles => :web do
    puts "Executing: mongrel_rails cluster::start -C #{mongrel_conf}"
    run "mongrel_rails cluster::start -C #{mongrel_conf}"
  end

  remote_task :stop, :roles => :web do
    puts "Executing: mongrel_rails cluster::stop -C #{mongrel_conf}"
    run "mongrel_rails cluster::stop -C #{mongrel_conf}"
  end
  
  remote_task :restart, :roles => :web do
    puts "Executing: mongrel_rails cluster::restart -C #{mongrel_conf}"
    run "mongrel_rails cluster::restart -C #{mongrel_conf}"
  end
  
  desc "Symlinks the configuration files"
  remote_task :symlink_config, :roles => :web do
    %w(database.yml mongrel_cluster.yml production.sphinx.conf).each do |file|
      run "ln -s #{shared_path}/config/#{file} #{current_path}/config/#{file}"
    end
    
    run "ln -s #{shared_path}/config/recaptcha_keys.rb #{current_path}/config/initializers/recaptcha_keys.rb"
  end
  
  desc "Symlinks shared directories"
  remote_task :symlink_shared, :roles => :web do
    # Use shared sphinx index
    run "ln -s #{shared_path}/system/sphinx #{current_path}/db/sphinx"    
  end
  
  desc "Generate compressed Javascript and Stylesheet files"
  remote_task :asset_packager, :roles => :web do
    puts "Generating compressed Javascript and Stylesheet files"
    Rake::Task['asset:packager:build_all'].invoke
  end
 
  desc "Full deployment cycle: Update, migrate, restart, cleanup"
  remote_task :deploy, :roles => :app do
    Rake::Task['vlad:update'].invoke
    Rake::Task['vlad:symlink_config'].invoke
    Rake::Task['vlad:symlink_shared'].invoke
    Rake::Task['vlad:migrate'].invoke
    Rake::Task['vlad:restart'].invoke
    Rake::Task['vlad:cleanup'].invoke

    run 'cd #{current_release}; rake vlad:asset_packager'
    Rake::Task['vlad:sphinx_restart'].invoke
  end
  
  desc "Stop, index and start sphinx server"
  remote_task :sphinx_restart, :roles => :web do
    run "cd #{current_release}; rake ts:index RAILS_ENV=production"
    # should we restart the server?
    # run "cd #{current_release}; rake ts:restart RAILS_ENV=production"
  end
end