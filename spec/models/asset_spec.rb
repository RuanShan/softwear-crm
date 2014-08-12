require 'spec_helper'
include ApplicationHelper

describe Asset, asset_spec: true do

  it { is_expected.to be_paranoid }
  
  describe 'Relationships' do
    it { is_expected.to belong_to(:assetable) }
    it { is_expected.to have_attached_file(:file) }
  end

  describe 'Validations' do
    it { is_expected.to validate_presence_of(:description) }
    it { is_expected.to validate_attachment_presence(:file) }
    it { is_expected.to validate_attachment_content_type(:file) }
    it { is_expected.to validate_attachment_size(:file).less_than(120.megabytes)  }
  end
end
