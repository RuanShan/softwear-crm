
# ec2_role :app, user: 'ubuntu'
# ec2_role :db, user: 'ubuntu'
# ec2_role :web, user: 'ubuntu'
# ec2_role :cron, user: 'ubuntu'
# ec2_role :redis, user: 'ubuntu'

server '50.19.126.7', user: 'ubuntu', roles: %w{web app redis} # , my_property: :my_value
server '54.161.180.55', user: 'ubuntu', roles: %w{web app} # , my_property: :my_value
server 'production.softwearcrm.com', user: 'ubuntu', roles: %w{web app db cron} # , my_property: :my_value

set :branch, 'master'

set :linked_files, fetch(:linked_files) + %w{config/sidekiq.yml}
