FactoryGirl.define do
  factory :valid_color, class: Color do
    sequence(:name) { |n| "color_#{n}" }
    sequence(:sku) { |n|
      n %= 1000
      if n < 10
        "00#{n}"
      elsif n < 100 and n >= 10
        "0#{n}"
      else
        n
      end
    }
  end
end
