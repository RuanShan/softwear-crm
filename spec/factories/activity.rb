FactoryGirl.define do
  factory :proof_activity, class: PublicActivity::Activity do
    trackable { |t| t.association(:valid_proof) }
    after(:create) do |activity|
      activity.recipient = activity.trackable.order
    end
  end
end
