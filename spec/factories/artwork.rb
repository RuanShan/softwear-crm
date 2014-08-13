FactoryGirl.define do
  factory :blank_artwork, class: Artwork do

    factory :valid_artwork do
      name 'Artwork'
      description 'This is artwork'

      before(:create) do |artwork|
        artwork.artist_id = create(:user).id
        artwork.preview.file = create(:valid_asset).file
        artwork.preview.description = create(:valid_asset).description
        artwork.artwork.file = create(:valid_asset).file
        artwork.artwork.description = create(:valid_asset).description
      end
    end
  end
end
