FactoryGirl.define do
  factory :blank_artwork, class: Artwork do

    factory :valid_artwork do
      name 'Artwork'
      description 'This is artwork'
      local_file_location '~/spec/fixtures/images/test.psd'

      artwork do |a|
        a.association(
          :valid_asset,
          file: File.open("#{Rails.root}" + '/spec/fixtures/images/test.psd'),
        )
      end
      preview { |p| p.association(:valid_asset) }

      artist { |a| a.association(:user) }
    end
  end
end
