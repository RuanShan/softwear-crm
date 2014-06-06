require 'spec_helper'

describe InkColor do

  describe 'Validations' do
    it { should validate_presence_of(:name) }
    # it { should validate_uniqueness_of(:name).scoped_to :imprint_method}
    # figure out a way to include conditions: -> { where(deleted_at: nil)} into the validation
  end


  describe 'Relationships' do
    it { should belong_to(:imprint_method) }
  end

  describe 'Scopes' do
    let!(:ink_color) {create(:valid_ink_color)}
    let!(:deleted_ink_color) { create(:valid_ink_color, deleted_at: Time.now)}

    describe 'default_scope' do
      it 'includes only ink_colors where deleted_at is nil' do
        expect(InkColor.all).to eq([ink_color])
      end
    end

    describe 'deleted' do
      it 'includes only imprint_methods where deleted_at is not nil' do
        expect(InkColor.all).to eq([ink_color])
      end
    end
  end

  describe 'really_destroy!' do
    let!(:ink_color) { create(:valid_ink_color, deleted_at: Time.now)}

    it 'returns true if deleted_at is set' do
      expect(ink_color.really_destroy!).to eq(ink_color)
    end
  end

  describe '#destroyed?' do
    let!(:ink_color) { create(:valid_ink_color, deleted_at: Time.now)}

    it 'returns true if deleted_at is set' do
      expect(ink_color.destroyed?).to be_truthy
    end
  end

  describe '#destroy' do
    let!(:ink_color) { create(:valid_ink_color)}

    it 'sets deleted_at to the current time' do
      ink_color.destroy
      expect(ink_color.deleted_at).to_not be_nil
    end
  end

end