require 'softwear/lib/capistrano'
lock '3.2.1'

set :application, 'softwear-crm'
set :repo_url, 'git@github.com:annarbortees/softwear-crm.git'
set :rvm_ruby_string, 'ruby-2.1.1'
set :rvm_ruby_version, 'ruby-2.1.1'
set :rvm_task_ruby_version, 'ruby-2.1.1'
set :whenever_identifier, -> { "#{fetch(:application)}_#{fetch(:stage)}" }
set :assets_role, :web

set :deploy_to, '/home/ubuntu/RailsApps/crm.softwearcrm.com'
set :linked_files, %w{config/database.yml config/application.yml
                      config/sunspot.yml config/sidekiq.yml}

set :no_reindex, true
Softwear::Lib.capistrano(self)


namespace :puma do
  desc 'Create Directories for Puma Pids and Socket'
  task :make_dirs do
    on roles(:app) do
      execute "mkdir #{shared_path}/tmp/sockets -p"
      execute "mkdir #{shared_path}/tmp/pids -p"
    end
  end

  before :start, :make_dirs
end

namespace :deploy do
  desc "Make sure local git is in sync with remote."
  task :check_revision do
    on roles(:app) do
      unless `git rev-parse HEAD` == `git rev-parse origin/master`
        puts "WARNING: HEAD is not the same as origin/master"
        puts "Run `git push` to sync changes."
        exit
      end
    end
  end

  desc 'Initial Deploy'
  task :initial do
    on roles(:app) do
      before 'deploy:restart', 'puma:start'
      invoke 'deploy'
    end
  end

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      invoke 'puma:restart'
    end
  end

  # before :starting,     :check_revision
  after  :finishing,    :compile_assets
  after  :finishing,    :cleanup
  after  :finishing,    :restart
end
