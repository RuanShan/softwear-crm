FactoryGirl.define do
  factory :valid_color, class: Color do
    sequence(:name) { |n| "color_#{n}" }
    sequence(:sku) { |n|
      if (n %= 1000) >= 100
        n
      else
        (n >= 10) ? "0#{n}": "00#{n}"
      end
    }
  end

  factory :blank_color, class: Color do
  end
end
