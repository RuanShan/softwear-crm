FactoryGirl.define do
  factory :blank_artwork_request, class: ArtworkRequest do

    factory :artwork_request do
      deadline '06/05/2014 03:07 PM'
      description 'Description'
      priority 'Normal'
    end

    factory :valid_artwork_request do
      deadline '06/05/2014 03:07 PM'
      description 'Description'
      priority 'Normal'

      before(:create) do |artwork_request|
        create(:valid_imprint_method_with_color_and_location)
        artwork_request.salesperson_id = create(:alternate_user).id
        artwork_request.imprints << create(:valid_imprint) if artwork_request.imprints.empty?
        artwork_request.save(validate: false)
        artwork_request.artwork_request_ink_colors << ArtworkRequestInkColor.new(artwork_request_id: artwork_request.id, ink_color_id: create(:ink_color).id)
      end

      factory :valid_artwork_request_with_artist do
        before(:create) do |artwork_request|
          artwork_request.artist = create(:user)
        end 
      end

      factory :valid_artwork_request_with_asset do
        after(:create) { |ar| ar.assets << create(:valid_asset) }
      end

      factory :valid_artwork_request_with_artwork do
        after(:create) { |ar| ar.artworks << create(:valid_artwork) }
      end

      factory :valid_artwork_request_with_asset_and_artwork do
        after(:create) { |ar| ar.artworks << create(:valid_artwork) }
        after(:create) { |ar| ar.assets << create(:valid_asset) }
      end
    end
  end
end
