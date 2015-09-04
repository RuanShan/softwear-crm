FactoryGirl.define do
  factory :coupon do
    sequence(:name) { |n| "Factory Coupon ##{n}" }

    valid_from 2.days.ago
    valid_until 2.days.from_now

    Coupon::CALCULATORS.each do |calc, _|
      factory calc do
        calculator calc
        value 10.0
      end
    end
  end
end
