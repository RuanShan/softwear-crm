require 'spec_helper'
include ApplicationHelper

describe Artwork, artwork_spec: true do

  it { is_expected.to be_paranoid }

  describe 'Relationships' do
    it { is_expected.to belong_to(:artwork) }
    it { is_expected.to belong_to(:preview) }
    it { is_expected.to have_many(:artwork_requests) }
    it { is_expected.to accept_nested_attributes_for(:artwork) }
    it { is_expected.to accept_nested_attributes_for(:preview) }
  end

  describe 'Validations' do
    it { is_expected.to validate_presence_of(:name) }
  end

  describe '#is_image?' do

    let(:artwork) { create(:valid_artwork) }
    let(:artwork_doc_type) { create(:doc_type_preview) } 

    context 'Given an .png file' do 
      it 'should return true' do 
        expect(artwork.is_image?).to eq(true)
      end
    end

    context 'Given a .doc file' do 
      it 'should return false' do
        expect(artwork_doc_type.is_image?).to eq(false) 
      end
    end
  end

  describe '#show_tags' do
    let(:artwork) { create(:valid_artwork) }
    context 'Given an artwork with tag_list ["Test", "Test2", "Test3"]' do 
      it 'should return "Test, Test2, Test3"' do 
        expect(artwork.show_tags).to eq("Test, Test2, Test3")
      end
    end
  end
end
