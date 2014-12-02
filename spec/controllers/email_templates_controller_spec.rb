require 'spec_helper'

describe EmailTemplatesController, email_template_spec: true do
  let!(:valid_user) { create(:alternate_user) }
  before(:each) { sign_in valid_user }

# Not sure which controller methods i'll need
end
