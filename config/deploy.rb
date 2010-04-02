# set :mongrel_conf, "#{deploy_to}/current/config/mongrel_cluster.yml"

## OLD
set :user, "wifitocke"
set :domain, "#{user}@s3.ruby.si"
set :ssh_flags, "-p 65022"
set :application, "wifi-tocke.si"
set :deploy_to, "/home/wifitocke/#{application}"
set :repository, "git@github.com:lenart/wifi-spots.git"

set :mongrel_conf, "#{deploy_to}/current/config/mongrel_cluster.yml"

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
    %w(database.yml mongrel_cluster.yml).each do |file|
      run "ln -s #{shared_path}/config/#{file} #{current_path}/config/#{file}"
    end
  end
 
  desc "Full deployment cycle: Update, migrate, restart, cleanup"
  remote_task :deploy, :roles => :app do
    Rake::Task['vlad:update'].invoke
    Rake::Task['vlad:symlink_config'].invoke
    Rake::Task['vlad:migrate'].invoke
    Rake::Task['vlad:start_app'].invoke
    Rake::Task['vlad:cleanup'].invoke

    # Sphinx setup
    Rake::Task['ts:conf'].invoke
    Rake::Task['ts:index'].invoke
  end
end