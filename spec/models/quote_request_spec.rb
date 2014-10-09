require 'spec_helper'

describe QuoteRequest, quote_request_spec: true, story_78: true do
  it { is_expected.to have_db_column(:name).of_type(:string) }
  it { is_expected.to have_db_column(:email).of_type(:string) }
  # it { is_expected.to have_db_column(:approx_quantity).of_type(:decimal) }
  it { is_expected.to have_db_column(:date_needed).of_type(:datetime) }
  it { is_expected.to have_db_column(:description).of_type(:string) }
  it { is_expected.to have_db_column(:source).of_type(:string) }

  it { is_expected.to have_db_column(:created_at).of_type(:datetime) }
  it { is_expected.to have_db_column(:updated_at).of_type(:datetime) }
end