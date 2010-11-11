set :application, "wifi-tocke.si"
set :ssh_flags, "-p 65022"
set :repository, "git@github.com:lenart/wifi-spots.git"

task :staging do
  set :user, "formitas"
  set :domain, "#{user}@91.185.222.91"
  
  set :deploy_to, "/home/formitas/www/staging.#{application}"
  
  set :revision, "origin/oauth"
  
  namespace :vlad do
    remote_task :restart, :roles => :web do
      run "touch #{current_path}/tmp/restart.txt"
    end
  end
end

task :production do
  set :user, "wifitocke"
  set :domain, "#{user}@s3.ruby.si"
  
  set :deploy_to, "/home/wifitocke/#{application}"

  set :mongrel_conf, "#{deploy_to}/current/config/mongrel_cluster.yml"
  set :mongrel_environment, 'production'
  set :whenever_path, '/home/wifitocke/.gem/ruby/1.8/bin/'
  
  
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
    
  end
end

namespace :vlad do
  
  desc "Symlinks the configuration files"
  remote_task :symlink_config, :roles => :web do
    %w(database.yml mongrel_cluster.yml production.sphinx.conf).each do |file|
      puts "Symlinking #{file}"
      run "ln -s #{shared_path}/config/#{file} #{current_path}/config/#{file}"
    end
    
    puts "Symlinking reCaptcha keys (recaptcha_keys.rb)"
    run "ln -s #{shared_path}/config/recaptcha_keys.rb #{current_path}/config/initializers/recaptcha_keys.rb"
    puts "Symlinking backup directory"
    run "ln -s #{shared_path}/backup/ #{current_path}/db/backup"
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

    Rake::Task['vlad:asset_packager'].invoke
    Rake::Task['vlad:update_crontab'].invoke
    Rake::Task['vlad:sphinx_restart'].invoke
  end
  
  desc "Stop, index and start sphinx server"
  remote_task :sphinx_restart, :roles => :web do
    run "cd #{current_release}; rake ts:index RAILS_ENV=production"
    # should we restart the server?
    # run "cd #{current_release}; rake ts:restart RAILS_ENV=production"
  end
  
  desc "Update the crontab file"
  remote_task :update_crontab, :roles => :app do
    run "cd #{release_path} && #{whenever_path}whenever --update-crontab #{application}"
  end
end