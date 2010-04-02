# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require(File.join(File.dirname(__FILE__), 'config', 'boot'))

require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

require 'tasks/rails'
require 'thinking_sphinx/tasks'

begin
  require 'vlad'
  Vlad.load :scm => :git
rescue LoadError
  puts 'Could not load Vlad (in Rakefile)'
end