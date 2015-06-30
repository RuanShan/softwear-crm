require 'spec_helper'

describe ImprintablePhoto do
  describe 'Relationships' do
    it { is_expected.to belong_to :color }
    it { is_expected.to belong_to :imprintable }
    it { is_expected.to have_one :asset }
  end

  describe 'Validations' do
    it { is_expected.to validate_presence_of :asset }
    it { is_expected.to validate_presence_of :imprintable }
    it { is_expected.to validate_presence_of :color }
  end

  describe 'default' do
    context 'when an imprintable photo is set to be default', story_717: true do
      let!(:imprintable) { create(:valid_imprintable, imprintable_photos: [create(:imprintable_photo), create(:default_imprintable_photo)]) }
      let(:photos) { imprintable.imprintable_photos }

      it "unsets the imprintable's existing default photo" do
        expect(photos.first).to_not be_default
        expect(photos.last).to be_default

        photos.first.update_attributes! default: true

        photos.each(&:reload)
        expect(photos.first).to be_default
        expect(photos.last).to_not be_default
      end
    end
  end
end
