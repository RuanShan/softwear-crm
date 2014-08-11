FactoryGirl.define do
  factory :valid_asset, class: Asset do
    description 'This is an asset'
    file File.open("#{Rails.root}" + '/spec/fixtures/images/macho.jpg')
  end
end
