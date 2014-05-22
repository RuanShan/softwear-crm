FactoryGirl.define do
  factory :valid_imprintable_variant, class: ImprintableVariant do
    sequence(:imprintable_id) { |n| "imprintable_id#{n}"}
    weight 'Test Weight'
  end
end