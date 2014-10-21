require 'spec_helper'
include ApplicationHelper

describe QuoteRequestQuote, quote_request_quote_spec: true, story_79: true do

  it { is_expected.to be_paranoid }

  describe 'Relationships' do
    it { is_expected.to belong_to(:quote) }
    it { is_expected.to belong_to(:quote_request) }
  end

  describe 'Validations' do
    it { is_expected.to validate_uniqueness_of(:quote_request_id).scoped_to(:quote_id) }
  end
end