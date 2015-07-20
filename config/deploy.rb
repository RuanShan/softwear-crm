require 'softwear/lib'
# config valid only for Capistrano 3.1
lock '3.2.1'

set :application, 'softwear-crm'
set :repo_url, 'git@github.com:annarbortees/softwear-crm.git'
set :rvm_ruby_string, 'rbx-2.5.2'
set :rvm_ruby_version, 'rbx-2.5.2'
set :rvm_task_ruby_version, 'rbx-2.5.2'
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

Softwear::Lib.capistrano(self)

namespace :deploy do

  desc 'Restart application'
  task :restart do
    on roles([:web, :app]), in: :sequence, wait: 5 do
      execute :mkdir, '-p', "#{ release_path }/tmp"
      execute :touch, release_path.join('tmp/restart.txt')
    end
  end


  after :publishing, :restart

end

namespace :data do

  desc 'Dump data in envrionment into seed files'
  task :dump do
    on roles(:db) do
      within release_path do
        with rails_env: (fetch(:rails_env) || fetch(:stage)) do
          execute :rake, 'db:data:dump'
        end
      end
    end
  end

  desc 'Copy remote data to local server'
  task :download do
    run_locally do
      execute "scp ubuntu@crm.softwearcrm.com:#{release_path}/db/data.yml ./db/data.yml"
      execute :rake, 'db:data:load'
    end
  end
end
