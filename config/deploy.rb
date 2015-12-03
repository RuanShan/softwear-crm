require 'softwear/lib'
# config valid only for Capistrano 3.1
lock '3.2.1'

set :application, 'softwear-crm'
set :repo_url, 'git@github.com:annarbortees/softwear-crm.git'
set :rvm_ruby_string, 'rbx-2.5.2'
set :rvm_ruby_version, 'rbx-2.5.2'
set :rvm_task_ruby_version, 'ruby-2.1.2'
set :whenever_identifier, -> { "#{fetch(:application)}_#{fetch(:stage)}" }
set :assets_role, :web

# Default branch is :master
ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }.call

# Default deploy_to directory is /var/www/my_app
set :deploy_to, '/home/ubuntu/RailsApps/crm.softwearcrm.com'

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
set :linked_files, %w{config/database.yml config/application.yml
                      config/sunspot.yml config/sidekiq.yml}

# Default value for linked_dirs is []
# set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

# NOTE add `set :no_reindex, true` to not reindex solr
set :no_reindex, true
Softwear::Lib.capistrano(self)
