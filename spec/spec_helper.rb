# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'rake'

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

# Checks for pending migrations before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.check_pending! if defined?(ActiveRecord::Migration)

I18n.enforce_available_locales = false

RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
  config.include FormHelpers
  config.include AuthenticationHelpers
  config.include GeneralHelpers
  config.include Devise::TestHelpers, type: :controller
  config.extend ControllerMacros, type: :view
  config.include Devise::TestHelpers, type: :view
  config.include SunspotMatchers
  

  # ## Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  Capybara.register_driver :selenium do |app|
    Capybara::Selenium::Driver.new(app, :browser => :chrome)
  end

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = false

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  config.order = "random"

  config.before(:each, solr: false) do
    Sunspot.session = SunspotMatchers::SunspotSessionSpy.new(Sunspot.session)
  end

  # TODO MONDAY
  # Doesn't build the rake tasks properly, look at the chrome thing that's hopfully already up and it should lead you to victory
  # 
  config.before(:each, solr: true) do
    Rake::Task['sunspot:solr:start'].invoke
  end

  config.after(:each, solr: true) do
    Rake::Task['sunspot:solr:stop'].invoke
  end

  config.before(:suite) do
    DatabaseCleaner.strategy = :truncation
  end
  config.before(:each) do
    DatabaseCleaner.start
  end
  config.after(:each) do
    # I found that sometimes, the database cleaner would start truncating tables
    # before the last test was finished.
    sleep 0.5
    DatabaseCleaner.clean
  end

end
