require 'spec_helper'

describe Imprint, imprint_spec: true do
  let(:imprint) { create :valid_imprint }
  let(:print_location) { imprint.print_location }

  it { is_expected.to be_paranoid }

  describe 'Relationships' do
    it { is_expected.to belong_to :job }
    it { is_expected.to belong_to :print_location }
    it { is_expected.to have_one(:imprint_method).through(:print_location) }
    # it { is_expected.to have_one(:order).through(:job) }
    context 'when testing story-189', story_189: true do
      it { is_expected.to have_many :name_numbers }
    end
  end

  describe 'Validations' do
    it { is_expected.to validate_presence_of :print_location }
    # FIXME why doesn't this work?
    # it { is_expected.to validate_uniqueness_of(:print_location).scoped_to(:job_id) }
  end

  describe 'when updated', update: true do
    before do
      allow_any_instance_of(PrintLocation).to receive(:update_popularity)
    end

    it 'updates print location popularity', popularity: true do
      allow(PrintLocation).to receive(:find).with(print_location.id).and_return print_location
      expect(print_location).to receive(:update_popularity)

      imprint.description = 'New desc'
      imprint.save!
    end
  end

  describe '#name' do
    before do
      allow(subject).to receive(:imprint_method) { build_stubbed(:blank_imprint_method, name: 'IM name') }
      allow(subject).to receive(:print_location) { build_stubbed(:blank_print_location, name: 'PL name') }
      allow(subject).to receive(:description) { '1CF' }
    end

    it 'returns a string of imprint_method.name - print_location.name' do
      expect(subject.name).to eq("IM name - PL name - 1CF")
    end
  end

  describe 'with many artwork requests', story_864: true do
    let!(:other_job) { create(:order_with_job).jobs.first }
    let!(:artwork_request_1) { create(:valid_artwork_request_with_artwork, imprints: [imprint]) }
    let!(:artwork_request_2) { create(:valid_artwork_request_with_artwork, imprints: [imprint]) }
    let!(:artwork_request_3) { create(:valid_artwork_request_with_artwork, imprints: [imprint]) }
    let!(:proof) { create(:proof, job: imprint.job, artworks: [artwork_request_2.artworks.first]) }
    let!(:irrelevant_proof) { create(:proof, job: other_job, artworks: [artwork_request_1.artworks.first]) }

    specify '#artworks returns the artworks from the artwork_requests that are also inside a proof for the job' do
      expect(imprint.artworks.to_a).to eq [artwork_request_2.artworks.first]
    end

    specify '#proofs returns the proofs that contain art within the imprint artwork requests' do
      expect(imprint.proofs.to_a).to eq [proof]
    end
  end

  describe '#number_count' do
    context 'the imprint has a set of name_numbers with numbers' do
      let(:imprint){ create(:imprint_with_name_number) }

      it 'returns a hash of each number and the amount of times it occurs' do
        allow_any_instance_of(Imprint).to receive(:name_numbers) { [build(:number_12), build(:number_33), build(:number_39)]}
        expect(imprint.number_count).to eq( {"1" => 1, "2" => 1, "3" => 3, "9" => 1 } )
      end
    end
  end

end
