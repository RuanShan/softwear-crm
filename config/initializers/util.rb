# include stuff in lib/util
Dir[Rails.root + 'lib/util/**/*.rb'].each do |file|
	require file
end

# Make sure that injectables are always accessible and up-to-date
# and also that they don't need to be module-namespaced based on folder name.
Rails.application.config.to_prepare do
  Dir[Rails.root + 'app/helpers/injectables/**/*.rb'].each do |file|
    load file
  end
end

# To ease insightly testing
# (not relevant to requiring util directory)
Insightly2.api_key = ENV['INSIGHTLY_API_KEY'] if Rails.env.development?

Softwear::Lib.fix_sort_argument_error_on_rubinius
