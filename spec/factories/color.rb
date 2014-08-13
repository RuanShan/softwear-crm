FactoryGirl.define do
  factory :blank_color, class: Color do

    factory :valid_color do
      sequence(:name) { |n| "color_#{n}" }
      sequence(:sku) { |n|
        if (n %= 1000) >= 100
          n
        else
          (n >= 10) ? "0#{n}": "00#{n}"
        end
      }
    end
  end
end
