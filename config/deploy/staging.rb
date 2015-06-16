set :branch, 'develop'
set :linked_files, fetch(:linked_files) + %w{config/remote_database.yml}
set :bundle_flags, '--deployment' # No --quiet for staging

server '50.17.187.22', user: 'ubuntu', roles: %w{web app db} # , my_property: :my_value

