require 'bundler/capistrano'
require "whenever/capistrano"

# Whenever (CRON)
set :whenever_command, "bundle exec whenever"
# set :whenever_environment, defer { stage }
set :whenever_identifier, defer { "#{application}_#{stage}" }
set :job_template, "/usr/local/bin/bash -l -c ':job'"


server "wifitocke@s3.ruby.si", :app, :web, :db, :primary => true
set :application, "wifi-tocke.si"
set :deploy_to, "/home/wifitocke/tmp/#{application}"
set :scm, :git
set :repository, "git@github.com:lenart/wifi-spots.git"
set :user, "wifitocke"
set :domain, "#{user}@s3.ruby.si"
set :port, 65022
set :use_sudo, false


set :normalize_asset_timestamps, false  # don't touch /images/javascripts, /images/stylesheets, ...


set :mongrel_conf, "#{deploy_to}/current/config/mongrel_cluster.yml"
set :mongrel_environment, 'production'
# set :whenever_path, '/home/wifitocke/.gem/ruby/1.8/bin/'

namespace :deploy do

  task :start, :roles => :web do
    puts "Executing: mongrel_rails cluster::start -C #{mongrel_conf}"
    run "mongrel_rails cluster::start -C #{mongrel_conf}"
  end

  task :stop, :roles => :web do
    puts "Executing: mongrel_rails cluster::stop -C #{mongrel_conf}"
    run "mongrel_rails cluster::stop -C #{mongrel_conf}"
  end
  
  task :restart, :roles => :web do
    puts "Executing: mongrel_rails cluster::restart -C #{mongrel_conf}"
    run "mongrel_rails cluster::restart -C #{mongrel_conf}"
  end
  
  desc "Symlinks the configuration files and folders"
  task :symlink_config, :roles => :web do
    %w(database.yml mongrel_cluster.yml production.sphinx.conf).each do |file|
      puts "Symlinking #{file}"
      run "ln -s #{shared_path}/config/#{file} #{latest_release}/config/#{file}"
    end
    
    puts "Symlinking reCaptcha keys (recaptcha_keys.rb)"
    run "ln -s #{shared_path}/config/recaptcha_keys.rb #{latest_release}/config/initializers/recaptcha_keys.rb"
    puts "Symlinking backup directory"
    run "ln -s #{shared_path}/backup/ #{latest_release}/db/backup"
    puts "Symlinking sphinx directory"
    run "ln -s #{shared_path}/system/sphinx #{latest_release}/db/sphinx"
  end
  before "deploy:assets:precompile", "deploy:symlink_config"
  
  
  desc "Stop, index and start sphinx server"
  task :sphinx_restart, :roles => :web do
    run "cd #{current_release}; rake ts:index RAILS_ENV=production"
    # should we restart the server?
    # run "cd #{current_release}; rake ts:restart RAILS_ENV=production"
  end

end