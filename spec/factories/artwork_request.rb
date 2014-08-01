FactoryGirl.define do
  factory :valid_artwork_request, class: ArtworkRequest do
    artwork_status 'Pending'
    deadline '06/05/2014 03:07 PM'
    description 'Description'
    priority 'Normal'

    before(:create) do |artwork_request|
      # order = create(:order_with_job)
      imprint_method = create(:valid_imprint_method_with_color_and_location)
      artwork_request.artist_id = create(:user).id
      artwork_request.imprint_method_id = imprint_method.id
      artwork_request.salesperson_id = create(:alternate_user).id
      artwork_request.print_location_id = imprint_method.print_locations.first.id
      # artwork_request.job_ids = order.job_ids
      artwork_request.ink_color_ids = imprint_method.ink_color_ids
      artwork_request.jobs << create(:job)
    end

    # after(:create) do |artwork_request|
    #
    # end

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