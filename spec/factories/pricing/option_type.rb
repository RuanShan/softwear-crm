FactoryGirl.define do
  option_pool = ['Value One', 'Good Quality', 'Bad Quality', 'Type A', 'Type B', 'Type C', 'Type D', 'Secret', 'Public', 'Private']

  factory :option_type, class: Pricing::OptionType do
    sequence(:name) { |n| "Option Type #{n}" }
    options { [option_pool.sample, option_pool.sample, option_pool.sample] }
  end
end