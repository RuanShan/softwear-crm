FactoryGirl.define do
  factory :blank_ink_color, class: InkColor do
    colors = %w(Red Blue Yellow Green Orange Purple Brown Black White Cyan)

    factory :ink_color do
      sequence(:name) do |n|
        if n >= colors.size
          "#{colors[n]}#{n - colors.size}"
        else
          colors[n]
        end
      end
    end

    factory :valid_ink_color do
      name 'Red'
      # imprint_method { |ic| ic.association(:valid_imprint_method) }
    end
  end
end
