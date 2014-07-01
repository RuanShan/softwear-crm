FactoryGirl.define do
  factory :valid_artwork_request, class: ArtworkRequest do
    artwork_status 'Pending'
    deadline '06/05/2014 3:07 PM'
    description 'Description'

    before(:create) do |artwork_request|
      order = create(:order_with_job)
      imprint_method = create(:valid_imprint_method_with_color_and_location)
      artwork_request.artist_id = create(:user).id
      artwork_request.imprint_method_id = imprint_method.id
      artwork_request.salesperson_id = create(:alternate_user).id
      artwork_request.print_location = imprint_method.print_locations.first
      artwork_request.job_ids = order.job_ids
      artwork_request.ink_color_ids = imprint_method.ink_color_ids
    end
  end
end