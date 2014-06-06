require 'spec_helper'

describe ImprintMethod do

  describe 'Validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:production_name) }
    it { should validate_uniqueness_of(:production_name).scoped_to :name}
  end

  describe 'Relationships' do
    it { should have_many(:ink_colors) }
    # figure out a way to test accepts_nested_attr
  end

  describe 'Scopes' do
    let!(:imprint_method) { create(:valid_imprint_method_with_color)}
    let!(:deleted_imprint_method) { create(:valid_imprint_method, deleted_at: Time.now, name: 'Deleted')}

    describe 'default_scope' do
      it 'includes only imprint_methods where deleted_at is nil' do
        expect(ImprintMethod.all).to eq([imprint_method])
      end
    end

    describe 'deleted' do
      it 'includes only imprint_methods where deleted_at is not nil' do
        expect(ImprintMethod.all).to eq([imprint_method])
      end
    end
  end

  describe 'really_destroy!' do
    let!(:imprint_method) { create(:valid_imprint_method_with_color, deleted_at: Time.now)}

    it 'returns true if deleted_at is set' do
      expect(imprint_method.really_destroy!).to eq(imprint_method)
    end
  end

  describe '#destroyed?' do
    let!(:imprint_method) { create(:valid_imprint_method_with_color, deleted_at: Time.now)}

    it 'returns true if deleted_at is set' do
      expect(imprint_method.destroyed?).to be_truthy
    end
  end

  describe '#destroy' do
    let!(:imprint_method) { create(:valid_imprint_method_with_color)}

    it 'sets deleted_at to the current time' do
      imprint_method.destroy
      expect(imprint_method.deleted_at).to_not be_nil
    end
  end
end