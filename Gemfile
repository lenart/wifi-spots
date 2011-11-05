# Edit this Gemfile to bundle your application's dependencies.
# This preamble is the current preamble for Rails 3 apps; edit as needed.
source 'http://rubygems.org'

gem 'rails', '3.1.1'
gem 'mysql2'
gem 'haml-rails'

# gem 'RedCloth'
gem 'rdiscount'   # Textile parser

gem 'inherited_resources'
gem 'will_paginate'

# gem 'geokit'
gem 'geokit-rails3'
# https://github.com/apneadiving/Google-Maps-for-Rails
# https://github.com/parolkar/cartographer
gem 'json'

gem 'friendly_id'
gem 'thinking-sphinx'
gem 'recaptcha', :require => "recaptcha/rails"
gem 'paper_trail', '~>2'
gem 'whenever', :require => false

gem 'nokogiri'  # used by Spot.import_gmaps_rss

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails'
  gem 'coffee-rails', "~> 3.1.0"
  gem 'uglifier'
end

gem 'jquery-rails'
gem 'swf_fu', :git => "git://github.com/rodrigob/swf_fu"

#
# User and permissions
#
# gem "cancan"
gem 'authlogic'


group :development, :test do
  gem 'cucumber-rails'
  gem 'rspec-rails'
  gem 'factory_girl'
  
  gem 'database_cleaner'
  gem 'webrat'
  
  gem 'spork', '~> 0.9.0.rc'

  # config.gem 'pickle'
  # config.gem "faker", :version => '>= 0.3.1'
end