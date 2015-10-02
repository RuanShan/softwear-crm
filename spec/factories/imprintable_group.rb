FactoryGirl.define do
  factory :imprintable_group do
    sequence(:name) { |n| "Imprintable Group ##{n}" }

    factory :imprintable_group_with_imprintables do
      after(:create) do |group|
        group.imprintable_imprintable_groups = [
          create(:good,   default: true, imprintable: create(:valid_imprintable)),
          create(:better, default: true, imprintable: create(:valid_imprintable)),
          create(:best,   default: true, imprintable: create(:valid_imprintable))
        ]
      end
    end
  end
end
