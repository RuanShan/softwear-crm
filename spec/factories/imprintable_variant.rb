FactoryGirl.define do
  factory :valid_imprintable_variant, class: ImprintableVariant do
    sequence(:imprintable_id) { |n| "imprintable_id#{n}"}
    size { |s| s.association(:valid_size) }
    color { |b| b.association(:valid_color) }
    imprintable { |i| i.association(:valid_imprintable) }
  end
end
