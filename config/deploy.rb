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

end

namespace :deploy do
  before :updated, :setup_solr_data_dir do
    on roles(:app) do
      unless test "[ -d #{shared_path}/solr/data ]"
        execute :mkdir, "-p #{shared_path}/solr/data"
      end
    end
  end
end

namespace :solr do

  %w[start stop].each do |command|
    desc "#{command} solr"
    task command do
      on roles(:app) do
        solr_pid = "#{shared_path}/pids/sunspot-solr.pid"
        if command == "start" or (test "[ -f #{solr_pid} ]" and test "kill -0 $( cat #{solr_pid} )")
          within current_path do
            with rails_env: fetch(:rails_env, 'production') do
              execute :bundle, 'exec', 'sunspot-solr', command, "--port=8983 --data-directory=#{shared_path}/solr/data --pid-dir=#{shared_path}/pids"
            end
          end
        end
      end
    end
  end

  desc "restart solr"
  task :restart do
    invoke 'solr:stop'
    invoke 'solr:start'
  end

  after 'deploy:finished', 'solr:restart'

  desc "reindex the whole solr database"
  task :reindex do
    invoke 'solr:stop'
    on roles(:app) do
      execute :rm, "-rf #{shared_path}/solr/data"
    end
    invoke 'solr:start'
    on roles(:app) do
      within current_path do
        with rails_env: fetch(:rails_env, 'production') do
          info "Reindexing Solr database"
          execute :bundle, 'exec', :rake, 'sunspot:solr:reindex[,,true]'
        end
      end
    end
  end

end
