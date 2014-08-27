module Api
  class Engine < ::Rails::Engine
    isolate_namespace Api

    config.generators do |g|
      g.test_framework :rspec, fixture: false
      g.fixture_replacement :factory_girl, dir: 'spec/features'
      g.assets false
      g.helper false
    end
  end
end
