FactoryGirl.define do
  factory :valid_imprintable, class: Imprintable do
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
    sequence(:style_name) { |n| "style_#{n}" }
    sequence(:style_sku) { |n|
      n %= 100
      if n < 10
        "0#{n}"
      else
        n
      end
    }
    sequence(:style_catalog_no) { |n| (1234+n).to_s }
    style_description 'description'



    before(:create) do |imprintable|
      brand = create(:valid_brand)
      imprintable.brand_id = brand.id
    end

  end

  factory :associated_imprintable, class: Imprintable do
  	style { |s| s.association(:associated_style) }
  	brand { |b| b.association(:valid_brand) }
  	sizing_category 'Ladies'
  end
end
