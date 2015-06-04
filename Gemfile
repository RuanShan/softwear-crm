source 'https://rubygems.org'

gem 'softwear-lib'
require 'softwear/lib'
Softwear::Lib.common_gems(self)

gem 'font-awesome-sass'
gem 'summernote-rails'

# For active_record_cookie store
gem 'activerecord-session_store', github: 'rails/activerecord-session_store'

# Makes it so save_and_open_page automatically opens page
gem 'launchy', '~> 2.4.2'

# use liquid to allow users to make custom templates
gem 'liquid'

# For tagging
gem 'acts-as-taggable-on'

# For encrypting db fields
gem 'attr_encrypted', '~> 1.3.3'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
#gem 'turbolinks'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 1.2'

gem 'sunspot_rails'

# for wicked-pdf
gem 'wkhtmltopdf-binary'
gem 'wicked_pdf'

gem 'funkify', github: 'Resonious/funkify', branch: :master

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

gem 'cap-ec2', group: :development

group :test do
  gem 'database_cleaner'
  gem 'sunspot_matchers'
  # for accessing session object in integration tests
  gem 'rack_session_access'
  # for faking redis (used by sidekiq)
  gem 'fakeredis', :require => 'fakeredis/rspec'
end

gem 'acts_as_commentable'
gem 'aws-sdk'
gem 'google_drive'
# gem 'api', path: 'engines/api'
gem 'remotipart'
gem 'public_activity', github: 'AnnArborTees/public_activity', branch: 'master'
gem 'sunspot_solr'
gem 'progress_bar'
gem 'insightly2', github: 'AnnArborTees/insightly-ruby'
gem 'freshdesk', github: 'annarbortees/freshdesk-api'
gem 'simple_token_authentication'
gem 'sinatra', require: false
gem 'sidekiq'
gem 'sidekiq-status'
gem 'sidekiq-failures'
gem 'x-editable-rails'
gem 'jquery-fileupload-rails'
gem 'php-serialize'
gem 'yaml_db', github: 'jetthoughts/yaml_db', ref: 'fb4b6bd7e12de3cffa93e0a298a1e5253d7e92ba'

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use unicorn as the app server
# gem 'unicorn'

# Use debugger
# gem 'debugger', group: [:development, :test]
