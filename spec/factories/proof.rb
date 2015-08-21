FactoryGirl.define do
  factory :blank_proof, class: Proof do

    factory :proof do
      status 'Pending'
      approve_by '06/05/2014 03:07 PM'
      order { |o| o.association(:order) }
    end

    factory :valid_proof do
      status 'Pending'
      approve_by '06/05/2014 03:07 PM'
      order { |o| o.association(:order) }
      before(:create) do |proof|
        proof.artworks = [create(:valid_artwork)]
      end
    end
  end
end
