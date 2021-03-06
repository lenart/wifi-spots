# Be sure to restart your server when you modify this file

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.8' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )
  # config.load_paths += Dir["#{RAILS_ROOT}/app/models/*"].find_all { |f| File.stat(f).directory? }

  # Specify gems that this application depends on and have them installed with rake gems:install  
  config.gem "haml", :version => '>= 2.0.6'
  config.gem "RedCloth", :version => ">= 4.1.9", :lib => "redcloth"
  config.gem "binarylogic-authlogic", :lib => "authlogic", :source => 'http://gems.github.com'
  config.gem "josevalim-inherited_resources", :lib => "inherited_resources", :source => 'http://gems.github.com'
  config.gem "mislav-will_paginate", :lib => 'will_paginate', :version => '>= 2.3.7', :source => 'http://gems.github.com'
  # config.gem 'thoughtbot-paperclip', :lib => 'paperclip', :source => 'http://gems.github.com'
  config.gem "geokit"
  config.gem 'vestal_versions', :version => ">= 1.0.2"
  config.gem "friendly_id", :version => ">= 3.0.2"
  config.gem 'thinking-sphinx', :lib => 'thinking_sphinx', :version => '>=1.3.16'
  config.gem "ambethia-recaptcha", :lib => "recaptcha/rails", :source => "http://gems.github.com"
  config.gem "whenever"
  
  # Only load the plugins named here, in the order given (default is alphabetical).
  # :all can be used as a placeholder for all plugins not explicitly named
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

  # Skip frameworks you're not going to use. To use Rails without a database,
  # you must remove the Active Record framework.
  # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector, :forum_observer
  config.action_mailer.default_url_options = { :host => "wifi-tocke.si" }

  # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
  # Run "rake -D time" for a list of tasks for finding time zone names.
  config.time_zone = 'UTC'

  # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
  # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}')]
  # config.i18n.default_locale = :de
end