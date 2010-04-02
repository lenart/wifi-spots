# set :mongrel_conf, "#{deploy_to}/current/config/mongrel_cluster.yml"

## OLD
set :user, "wifitocke"
set :domain, "#{user}@s3.ruby.si"
set :ssh_flags, '-p 65022'
set :application, "wifi-tocke.si"
set :deploy_to, "/home/wifitocke/#{application}"
set :repository, "git@github.com:lenart/wifi-spots.git"

set :mongrel_conf, '#{deploy_to}/current/config/mongrel_cluster.yml'

namespace :vlad do
  # invoke_command "mongrel_rails cluster::#{t.to_s} -C #{mongrel_conf}", :via => run_method 
  
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
    
    Rake::Task['ts:reindex'].invoke
  end
end

namespace :sphinx do
  desc "Restart sphinx server"
  remote_task :restart, :roles => :app do
    Rake::Task['ts:restart']
  end
end