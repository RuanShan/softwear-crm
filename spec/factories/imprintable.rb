FactoryGirl.define do
  factory :valid_imprintable, class: Imprintable do
    style { |s| s.association(:valid_style) }
    brand { |b| b.association(:valid_brand) }

    factory :valid_imprintable_with_valid_imprintable_variants do
      transient do
        valid_imprintable_variants_count 5
      end

      after(:create) do |valid_imprintable, evaluator|
        create_list(:valid_imprintable_variant, evaluator.valid_imprintable_variants_count, valid_imprintable: valid_imprintable)
        valid_imprintable.reload
      end
    end
  end
end
