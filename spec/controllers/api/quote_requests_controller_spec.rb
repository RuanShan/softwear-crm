require 'spec_helper'

describe Api::QuoteRequestsController, quote_request_spec: true, story_77: true, api_spec: true do
  let!(:valid_user) { create :alternate_user }
  before(:each) { sign_in valid_user }

  it_behaves_like 'api_controller create'
end
