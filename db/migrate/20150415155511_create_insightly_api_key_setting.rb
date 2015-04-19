class CreateInsightlyApiKeySetting < ActiveRecord::Migration
  def up
    setting = Setting.new(name: 'insightly_api_key', val: nil, encrypted: false)
    setting.save!(validate: false)
    puts 'Added insightly_api_key setting'
  end
end
