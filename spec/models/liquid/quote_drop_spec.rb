require 'spec_helper'

describe QuoteDrop, liquid: true do
  subject { QuoteDrop.new(build(:valid_quote) ) }
  it { is_expected.to respond_to(:id) }
  it { is_expected.to respond_to(:name) }
  it { is_expected.to respond_to(:customer_first_name) }
  it { is_expected.to respond_to(:customer_last_name) }
  it { is_expected.to respond_to(:customer_full_name) }
  it { is_expected.to respond_to(:customer_email) }
  it { is_expected.to respond_to(:customer_company) }
  it { is_expected.to respond_to(:customer_phone_number) }
  it { is_expected.to respond_to(:valid_until_date) }
  it { is_expected.to respond_to(:estimated_delivery_date) }
  it { is_expected.to respond_to(:shipping_cost) }
  it { is_expected.to respond_to(:line_item_groups) }
end