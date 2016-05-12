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
  end

  describe 'Validates asset differently if artwork or not' do
    let!(:asset_with_no_description) { create(:valid_asset, description: nil) }   
    
    context 'asset is an artwork and has no description' do
      it 'should still be valid' do
        expect(asset_with_no_description).to be_valid 
      end
    end

    context 'asset is not an artwork' do
      let!(:asset_with_description) { create(:valid_asset)}

      before :each do
        asset_with_description.update_column(:file_content_type, "script/js")
        asset_with_no_description.update_column(:file_content_type, "script/js")
        asset_with_description.save
        asset_with_no_description.save
      end

      it 'should be valid with a description' do
        expect(asset_with_description).to be_valid
      end

      it 'should be invalid without a description' do
        expect(asset_with_no_description).to_not be_valid
      end
    end
  end
end
