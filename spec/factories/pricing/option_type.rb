FactoryGirl.define do
  option_pool = ['Value One', 'Good Quality', 'Bad Quality', 'Type A', 'Type B', 'Type C', 'Type D', 'Secret', 'Public', 'Private']

  factory :option_type, class: Pricing::OptionType do
    imprint_method { |i| i.association(:valid_imprint_method) }
    sequence(:name) { |n| "Option Type #{n}" }
    options { [option_pool.sample, option_pool.sample, option_pool.sample] }
  end
end