FactoryGirl.define do
  factory :blank_asset, class: Asset do

    factory :valid_asset do
      description 'This is an asset'
      file File.open("#{Rails.root}" + '/spec/fixtures/images/macho.png')
    end

    factory :js_asset do
      description
    end
  end
end
