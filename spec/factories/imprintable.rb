FactoryGirl.define do
  factory :valid_imprintable, class: Imprintable do
    style { |s| s.association(:valid_style) }
    brand { |b| b.association(:valid_brand) }
    sizing_category 'Ladies'
    special_considerations 'Special Consideration'
    main_supplier 'SS-Activewear'
    supplier_link 'http://www.ssactivewear.com'
    weight '3.4 oz'
    base_price 9.99
    xxl_price 10.00
    xxxl_price 11.99
    xxxxl_price 12.99
    xxxxxl_price 13.99
    xxxxxxl_price 0
  end

  factory :associated_imprintable, class: Imprintable do
  	style { |s| s.association(:associated_style) }
  	brand { |b| b.association(:valid_brand) }
  	sizing_category 'Ladies'
  end
end
