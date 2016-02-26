set :user, 'ubuntu'

# server '50.19.126.7', roles: %w{web app redis} # , my_property: :my_value
server 'ec2-54-162-84-234.compute-1.amazonaws.com', user: 'ubuntu', roles: %w{web app db}

set :branch, 'story-1223-ricky'

set :linked_files, fetch(:linked_files) + %w{config/sidekiq.yml}

set :puma_threads,    [4, 16]
set :puma_workers,    0
# set :pty,             true
# set :use_sudo,        false
# set :deploy_via,      :remote_cache
set :puma_bind,       "unix://#{shared_path}/tmp/sockets/#{fetch(:application)}-puma.sock"
set :puma_state,      "#{shared_path}/tmp/pids/puma.state"
set :puma_pid,        "#{shared_path}/tmp/pids/puma.pid"
set :puma_access_log, "#{release_path}/log/puma.error.log"
set :puma_error_log,  "#{release_path}/log/puma.access.log"
set :ssh_options,     { forward_agent: true, user: 'ubuntu', keys: %w(~/.ssh/id_rsa.pub) }
# set :ssh_options,     { user: fetch(:user)} #, keys: %w(~/.ssh/id_rsa.pub), forward_agent: true }
set :puma_preload_app, true
set :puma_worker_timeout, nil
set :puma_init_active_record, true  # Change to false when not using ActiveRecord
