
ec2_role :app, user: 'ubuntu'
ec2_role :db, user: 'ubuntu'
ec2_role :web, user: 'ubuntu'
ec2_role :cron, user: 'ubuntu'
ec2_role :redis, user: 'ubuntu'

set :branch, 'master'

set :linked_files, fetch(:linked_files) + %w{config/sidekiq.yml}

