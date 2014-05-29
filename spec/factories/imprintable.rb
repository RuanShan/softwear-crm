FactoryGirl.define do
  factory :valid_imprintable, class: Imprintable do
    style { |s| s.association(:valid_style) }
    brand { |b| b.association(:valid_brand) }
  end
end
