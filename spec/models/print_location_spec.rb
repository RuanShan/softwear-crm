require 'spec_helper'

describe PrintLocation do

  describe 'Validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:max_height) }
    it { should validate_presence_of(:max_width) }
    # it { should validate_uniqueness_of(:name).scoped_to :imprint_method}
    # figure out a way to include conditions: -> { where(deleted_at: nil)} into the validation
  end


  describe 'Relationships' do
    it { should belong_to(:imprint_method) }
  end

  describe 'Scopes' do
    let!(:print_location) {create(:valid_print_location)}
    let!(:deleted_print_location) { create(:valid_print_location, deleted_at: Time.now)}

    describe 'default_scope' do
      it 'includes only print_locations where deleted_at is nil' do
        expect(PrintLocation.all).to eq([print_location])
      end
    end

    describe 'deleted' do
      it 'includes only print_locations where deleted_at is not nil' do
        expect(PrintLocation.all).to eq([print_location])
      end
    end
  end

  describe 'really_destroy!' do
    let!(:print_location) { create(:valid_print_location, deleted_at: Time.now)}

    it 'returns true if deleted_at is set' do
      expect(print_location.really_destroy!).to eq(print_location)
    end
  end

  describe '#destroyed?' do
    let!(:print_location) { create(:valid_print_location, deleted_at: Time.now)}

    it 'returns true if deleted_at is set' do
      expect(print_location.destroyed?).to be_truthy
    end
  end

  describe '#destroy' do
    let!(:print_location) { create(:valid_print_location)}

    it 'sets deleted_at to the current time' do
      print_location.destroy
      expect(print_location.deleted_at).to_not be_nil
    end
  end

end