require 'spec_helper'

describe Api::OrdersController, api_spec: true, story_199: true do
  let!(:valid_user) { create :alternate_user }
  before(:each) { sign_in valid_user }

  it_behaves_like 'api_controller index'
end