# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rspec/rails'
require 'rake'
require 'paperclip/matchers'
require 'public_activity/testing'
require 'email_spec'
require 'sidekiq/testing'
require 'fakeredis'
require 'softwear/lib'

# explicitly use fakeredis with sidekiq
redis_opts = { url: 'redis://127.0.0.1:6379/1', namespace: 'cms_queue' }
# If fakeredis is loaded, use it explicitly
redis_opts.merge!(driver: Redis::Connection::Memory) if defined?(Redis::Connection::Memory)

Sidekiq.configure_client do |config|
  config.redis = redis_opts
end

Sidekiq.configure_server do |config|
  config.redis = redis_opts
end

# This is so that we can get away with stubbing methods that should return
# ActiveRecord::Relations to return array.
Array.class_eval do
  def pluck(attr)
    map(&attr)
  end

  def reload
    self
  end
end

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }
include SunspotHelpers
include Softwear::Auth::Spec

# Checks for pending migrations before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.check_pending! if defined?(ActiveRecord::Migration)

I18n.enforce_available_locales = false

RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
  config.include FormHelpers
  config.include AuthenticationHelpers
  config.include GeneralHelpers
  # config.include Devise::TestHelpers, type: :controller
  config.extend ControllerMacros, type: :view
  # config.include Devise::TestHelpers, type: :view
  config.include SunspotMatchers
  config.include SunspotHelpers
  config.include Paperclip::Shoulda::Matchers
  config.include EmailSpec::Helpers
  config.include EmailSpec::Matchers
  config.include FormBuilderHelpers
  config.include SimulateDragSortable, type: :feature
  config.include Softwear::Lib::Spec
  config.include OrderHelpers
  config.include Softwear::Auth::Spec

  PublicActivity.enabled = false

  stub_authentication! config

  # ## Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  config.alias_it_should_behave_like_to :it_can, 'can'

  Capybara.register_driver :selenium do |app|
    args = ['--no-default-browser-check', '--no-sandbox', '--no-first-run', '--disable-default-apps']
    client = Selenium::WebDriver::Remote::Http::Default.new
    client.timeout = 360
    Capybara::Selenium::Driver.new(app, browser: :chrome, args: args, http_client: client)
  end

  config.define_derived_metadata(file_path: %r(/spec/controllers/)) do |meta|
    meta[:type] = :controller
  end
  config.define_derived_metadata(file_path: %r(/spec/views/)) do |meta|
    meta[:type] = :view
  end
  config.define_derived_metadata(file_path: %r(/spec/models/)) do |meta|
    meta[:type] = :model
  end

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = false

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false
  config.infer_spec_type_from_file_location!

  config.order = 'random'

  require 'rack_session_access/capybara'

  config.before(:each) do |example|
    example.metadata[:solr] ? lazy_load_solr : refresh_sunspot_session_spy

    allow_any_instance_of(Order).to receive(:enqueue_create_production_order)
  end

  config.before(:suite) do
    EndpointStub.activate!
    WebMock.disable_net_connect! allow_localhost: true

    Endpoint::Stub[Production::Order]
    Endpoint::Stub[Production::Job]
    Endpoint::Stub[Production::Imprint]
  end

  config.after(:suite) do
    stop_solr if solr_running?
  end

  config.before(:suite) do
    DatabaseCleaner.strategy = :truncation
  end
  config.before(:each) do
    DatabaseCleaner.start
  end
  config.after(:each) do
    DatabaseCleaner.clean
  end

end
