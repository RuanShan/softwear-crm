require 'capistrano/setup'
require 'capistrano/deploy'
require 'cap-ec2/capistrano'
require 'capistrano/rvm'
require 'capistrano/puma'
require 'capistrano/bundler'
require 'capistrano/rails/assets'
require 'capistrano/rails/migrations'
require 'whenever/capistrano'

# Loads custom tasks from `lib/capistrano/tasks' if you have any defined.
Dir.glob('lib/capistrano/tasks/*.rake').each { |r| import r }
