require 'spec_helper'

describe QuoteDrop, liquid: true do
  subject { QuoteDrop.new(build(:valid_quote) ) }
  let(:quote) { create(valid_quote) }
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
  it { is_expected.to respond_to(:jobs) }
  it { is_expected.to respond_to(:formal) }
  it { is_expected.to respond_to(:additional_options_and_markups) }
  it { is_expected.to respond_to(:notes) }
  it { is_expected.to respond_to(:comments) }
end
