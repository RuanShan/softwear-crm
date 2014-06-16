FactoryGirl.define do
  factory :valid_imprintable, class: Imprintable do
    style { |s| s.association(:valid_style) }
    brand { |b| b.association(:valid_brand) }
    sizing_category 'Ladies'
    special_considerations 'Special Consideration'
  end

  factory :associated_imprintable, class: Imprintable do
  	style { |s| s.association(:associated_style) }
  	brand { |b| b.association(:valid_brand) }
  	sizing_category 'Ladies'
  end
end
