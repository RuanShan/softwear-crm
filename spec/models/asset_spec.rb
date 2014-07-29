require 'spec_helper'
include ApplicationHelper

describe Asset, asset_spec: true do

  describe 'Validations' do
    it { should validate_presence_of(:description) }
    it { should validate_attachment_presence(:file) }
    it { should validate_attachment_content_type(:file) }
    it { should validate_attachment_size(:file).less_than(120.megabytes)  }
  end

  describe 'Relationships' do
    it { should belong_to(:assetable) }
    it { should have_attached_file(:file) }
  end

end