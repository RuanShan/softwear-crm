require 'spec_helper'

describe Api::ImprintablesController, api_imprintable_spec: true, api_spec: true do
  let!(:valid_user) { create :alternate_user }
  before(:each) { sign_in valid_user }

  it_behaves_like 'api_controller create'
  it_behaves_like 'a retailable api controller'
end