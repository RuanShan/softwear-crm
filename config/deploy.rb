# config valid only for Capistrano 3.1
lock '3.2.1'

set :application, 'softwear_crm'
set :repo_url, 'git@github.com:annarbortees/softwear-crm.git'
set :rvm_ruby_string, 'ruby-2.1.1'
set :whenever_identifier, -> { "#{fetch(:application)}_#{fetch(:stage)}" }

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
set :linked_files, %w{config/database.yml config/application.yml}

# Default value for linked_dirs is []
# set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

namespace :deploy do

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      # Your restart mechanism here, for example:
      execute :touch, release_path.join('tmp/restart.txt')
    end
  end

  after :publishing, :restart

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

  before :updated, :setup_solr_data_dir do
    on roles(:app) do
      unless test "[ -d #{shared_path}/solr/data ]"
        execute :mkdir, "-p #{shared_path}/solr/data"
      end
    end
  end

end

namespace :solr do
  rvm = '[[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm"'

  %i(start stop restart).each do |command|
    desc "#{command} solr"
    task command, [:env] do |_cmd, args|
      on roles(:app) do
        execute "cd #{current_path} && #{rvm} && bundle exec rake sunspot:solr:#{command} RAILS_ENV=#{fetch(:stage) || 'production'}"
      end
    end
  end

  after 'deploy:finished', 'solr:restart'

  desc 'reindex solr'
  task :reindex, [:env] do |_cmd, args|
    on roles(:app) do
      execute "cd #{current_path} && #{rvm} && yes | bundle exec rake sunspot:solr:reindex RAILS_ENV=#{fetch(:stage) || 'production'}"
    end
  end
end
