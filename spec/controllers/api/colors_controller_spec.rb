require 'spec_helper'
include ApiControllerTests

describe Api::ColorsController, api_color_spec: true, api_spec: true do
  let!(:valid_user) { create :alternate_user }
  before(:each) { sign_in valid_user }

  it_behaves_like 'api_controller create'
  it_behaves_like 'a retailable api controller'
end