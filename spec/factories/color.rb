FactoryGirl.define do
  factory :valid_color, class: Color do
    sequence(:name) { |n| "color_#{n}" }
    sequence(:sku) { |n| "sku_#{n}" }

    factory :valid_color_with_valid_imprintable_variants do
      transient do
        valid_imprintable_variants_count 5
      end

      after(:create) do |valid_color, evaluator|
        create_list(:valid_imprintable_variant, evaluator.valid_imprintable_variants_count, valid_color: valid_color)
        valid_color.reload
      end
    end
  end
end