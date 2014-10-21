require 'spec_helper'

describe Api::JobsController, api_spec: true, story_198: true do
  let!(:valid_user) { create :alternate_user }
  before(:each) { sign_in valid_user }
  
  it_behaves_like "api_controller index"
end