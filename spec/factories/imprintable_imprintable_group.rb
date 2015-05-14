FactoryGirl.define do
  factory :imprintable_imprintable_group do
    default false

    factory :good do
      tier Imprintable::TIER.good
    end
    factory :better do
      tier Imprintable::TIER.better
    end
    factory :best do
      tier Imprintable::TIER.best
    end
  end
end
