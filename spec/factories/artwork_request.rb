FactoryGirl.define do
  factory :valid_artwork_request, class: ArtworkRequest do
    artwork_status 'Pending'
    deadline '06/05/2014 3:07 PM'
    description 'hello'
  end
end