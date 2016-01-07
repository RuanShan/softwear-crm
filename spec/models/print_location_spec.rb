require 'spec_helper'

describe PrintLocation do

  it { is_expected.to be_paranoid }

  describe 'Relationships' do
    it { is_expected.to belong_to(:imprint_method) }
    it { is_expected.to have_many :imprints }
  end

  describe 'Validations' do
    it { is_expected.to validate_presence_of(:max_height) }
    it { is_expected.to validate_presence_of(:max_width) }
    it { is_expected.to validate_numericality_of (:max_height) }
    it { is_expected.to validate_numericality_of(:max_width) }
    it { is_expected.to validate_presence_of(:name) }
  end

  describe 'default scope' do
    let!(:pl1) { create(:valid_print_location) }
    let!(:pl2) { create(:valid_print_location) }
    let!(:pl3) { create(:valid_print_location) }

    before do
      create(:valid_imprint, print_location: pl1)

      create(:valid_imprint, print_location: pl2)
      create(:valid_imprint, print_location: pl2)
      create(:valid_imprint, print_location: pl2)

      create(:valid_imprint, print_location: pl3)
      create(:valid_imprint, print_location: pl3)
    end

    it 'is sorted by popularity (highest first)', popularity: true do
      expect(PrintLocation.all).to eq [pl2, pl3, pl1]
    end
  end

  describe '#update_popularity', popularity: true do
    subject { create(:valid_print_location) }

    it 'sets popularity to the amount of imprints with this location within the past 2 months' do
      initial_popularity = subject.popularity
      5.times { create(:valid_imprint, print_location: subject) }
      2.times { create(:valid_imprint, print_location: subject).tap { |i| i.update created_at: 1.year.ago, updated_at: 1.year.ago } }
      subject.update_popularity
      expect(subject.popularity).to eq initial_popularity + 5
    end
  end
end
