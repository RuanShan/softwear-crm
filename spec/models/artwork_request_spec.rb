require 'spec_helper'
include ApplicationHelper

describe ArtworkRequest, artwork_request_spec: true do

  it { is_expected.to be_paranoid }

  before(:each) do
    allow(RSpec::Mocks::Double).to receive(:primary_key).and_return 'id'
  end

  describe 'Relationships' do
    it { is_expected.to have_many(:imprint_methods) }
    it { is_expected.to have_many(:print_locations) }
    it { is_expected.to have_many(:assets) }
    it { is_expected.to have_many(:artworks) }
    it { is_expected.to have_many(:proofs).through(:artworks) }
    it { is_expected.to have_many(:ink_colors).through(:artwork_request_ink_colors) }
    it { is_expected.to have_many(:jobs) }
    it { is_expected.to accept_nested_attributes_for(:assets) }
  end

  describe 'Validations' do
    it { is_expected.to validate_presence_of(:deadline) }
    it { is_expected.to validate_presence_of(:description) }
    it { is_expected.to validate_presence_of(:ink_colors) }
    it { is_expected.to validate_presence_of(:priority) }
  end

  describe 'callbacks'  do
    describe 'after_save' do
      let(:artwork_request) { create(:valid_artwork_request, state: 'unassigned') }

      context 'when state is unassigned and artist_id is no longer null' do
        before do
          artwork_request.artist = create(:user)
          artwork_request.save
        end

        it 'advances to pending_artwork state' do
          expect(artwork_request.state).to eq('pending_artwork')
        end
      end
    end

    describe 'approval', artwork_request_approved: true do
      let!(:order) { create(:order_with_job) }
      let(:job) { order.jobs.first }
      let!(:artwork_request) { create(:valid_artwork_request_with_asset_and_artwork) }
      let(:dummy_ar3_1) { double('Ar3Train') }
      let(:dummy_ar3_2) { double('Ar3Train') }
      let(:dummy_digitization) { double('DigitizationTrain') }

      before do
        job.imprints << create(:valid_imprint).tap do |i|
          i.print_location.update_attributes imprint_method_id: create(:screen_print_imprint_method).id
        end
        job.imprints << create(:valid_imprint).tap do |i|
          i.print_location.update_attributes imprint_method_id: create(:dtg_imprint_method).id
        end
        artwork_request.imprints = job.imprints

        allow(job).to receive(:production?).and_return true
        allow(Job).to receive(:find).and_return job
        allow(Job).to receive(:delay).and_return Job
        allow(ArtworkRequest).to receive(:delay).and_return ArtworkRequest
        allow(ArtworkRequest).to receive(:find).and_return artwork_request
        allow_any_instance_of(Order).to receive(:softwear_prod_id).and_return 666

        artwork_request.update_column :state, :pending_manager_approval
      end

      specify 'trains are created based on relevant imprints when approved' do
        expect(Production::Ar3Train).to receive(:create)
          .with(order_id: order.softwear_prod_id, crm_artwork_request_id: artwork_request.id)
        expect(Production::ScreenTrain).to receive(:create)
          .with(order_id: order.softwear_prod_id, crm_artwork_request_id: artwork_request.id)
        expect(Production::DigitizationTrain).to_not receive(:create)

        artwork_request.approved_by = create(:user)
        artwork_request.approved
        artwork_request.save!
      end

      specify 'trains are destroyed when un-approved' do
        expect(dummy_ar3_1).to receive(:destroy)
        expect(dummy_ar3_2).to receive(:destroy)
        expect(dummy_digitization).to receive(:destroy)

        expect(Production::Ar3Train).to receive(:where)
          .with(crm_artwork_request_id: artwork_request.id)
          .and_return [dummy_ar3_1, dummy_ar3_2]
        expect(Production::DigitizationTrain).to receive(:where)
          .with(crm_artwork_request_id: artwork_request.id)
          .and_return [dummy_digitization]
        expect(Production::ScreenTrain).to receive(:where)
          .with(crm_artwork_request_id: artwork_request.id)
          .and_return []

        artwork_request.update_column :state, :manager_approved
        artwork_request.unassigned_artist
        artwork_request.save!
      end
    end
  end

  context 'after_creation'  do

    let(:artwork_request) { build(:artwork_request) }

    it 'default state is unassigned' do
      expect(artwork_request.state).to eq("unassigned")
    end

    it 'creates a freshdesk ticket', story_809: true
  end

  describe '#create_imprint_group_if_needed', imprint_group: true do
    let!(:user) { create(:user) }
    let!(:ink) { create(:ink_color) }

    let!(:prod_order) { create(:production_order) }
    let!(:order) { create(:order) }

    let!(:job_1) { create(:job, jobbable: order) }
    let!(:imprint_1_1) { create(:valid_imprint, job: job_1) }
    let!(:imprint_1_2) { create(:valid_imprint, job: job_1) }

    let!(:job_2) { create(:job, jobbable: order) }
    let!(:imprint_2_1) { create(:valid_imprint, job: job_2) }

    let!(:artwork_request) do
      create(
        :artwork_request,
        imprints:    [imprint_1_1, imprint_2_1],
        salesperson: user,
        ink_colors:  [ink]
      )
    end

    before(:each) do
      order.update_column :softwear_prod_id, prod_order.id
      [imprint_1_1, imprint_1_2, imprint_2_1].each do |imprint|
        prod_imprint = create(:production_imprint)
        imprint.update_column :softwear_prod_id, prod_imprint.id
      end
    end

    it 'generates an imprint group when the artwork request includes imprints across multiple jobs' do
      allow_any_instance_of(Order).to receive(:artwork_state).and_return 'ready_for_production'

      expect(artwork_request).to be_order_in_production

      artwork_request.create_imprint_group_if_needed

      expect(artwork_request.production?).to eq true
      expect(artwork_request.production.imprint_ids.size).to eq 2
    end
  end

  context '#freshdesk_proof_ticket', story_809: true do
    context 'no freshdesk artwork ticket exists' do
      it 'creates an artwork freshdesk ticket for the order'
    end

    context 'freshdesk artwork ticket exists' do
      it 'returns the ticket'
    end
  end

  context '#imprintable_variant_count' do
    before do
      jobs = [build_stubbed(:blank_job), build_stubbed(:blank_job), build_stubbed(:blank_job)]
      allow(jobs.first).to receive(:imprintable_variant_count).and_return(10)
      allow(jobs[1]).to receive(:imprintable_variant_count).and_return(0)
      allow(jobs[2]).to receive(:imprintable_variant_count).and_return(20)
      allow(subject).to receive(:jobs).and_return(jobs)
    end

    it 'returns the sum of all imprintable line item quantities from the artwork requests jobs' do
      expect(subject.imprintable_variant_count).to eq(30)
    end
  end

  context '#imprintable_variant_count with job having no line items (bug #176)' do
    before do
      job = [build_stubbed(:blank_job)]
      allow(job.first).to receive(:imprintable_variant_count).and_return(0)
      allow(subject).to receive(:jobs).and_return(job)
    end

    it 'returns zero' do
      expect(subject.imprintable_variant_count).to eq(0)
    end
  end

  context '#imprintable_info' do
    before do
      jobs = [build_stubbed(:blank_job), build_stubbed(:blank_job), build_stubbed(:blank_job)]
      allow(jobs.first).to receive(:imprintable_info).and_return('Imprintable Info 2001, More Imprintable Info 1998')
      allow(jobs[1]).to receive(:imprintable_info).and_return('Imprintable Info 2005')
      allow(jobs[2]).to receive(:imprintable_info).and_return('Imprintable Info 2009')
      allow(subject).to receive(:jobs).and_return(jobs)
    end

    it 'returns all of the information for the imprintables joined by commas' do
      expect(subject.imprintable_info).to eq('Imprintable Info 2001, More Imprintable Info 1998, Imprintable Info 2005, Imprintable Info 2009')
    end
  end

  context '#max_print_area', pending: true do
    let!(:print_location) { create(:blank_print_location, name: 'Chest', max_width: 9.1, max_height: 2.6) }
    before do
      jobs = [build_stubbed(:blank_job), build_stubbed(:blank_job), build_stubbed(:blank_job), build_stubbed(:blank_job)]
      allow(jobs.first).to receive(:max_print_area).and_return([3.1, 2.6])
      allow(jobs[1]).to receive(:max_print_area).and_return([3.1, 5.5])
      allow(jobs[2]).to receive(:max_print_area).and_return([5.5, 2.6])
      allow(jobs[3]).to receive(:max_print_area).and_return([5.5, 5.5])
      allow(subject).to receive(:jobs).and_return(jobs)
    end

    it 'returns the max print area from the artwork requests jobs' do
      expect(subject.max_print_area(print_location)).to eq('3.1 in. x 2.6 in.')
    end
  end

  context '#total_quantity' do
    before do
      jobs = [build_stubbed(:blank_job), build_stubbed(:blank_job), build_stubbed(:blank_job)]
      allow(jobs.first).to receive(:total_quantity).and_return(10)
      allow(jobs[1]).to receive(:total_quantity).and_return(0)
      allow(jobs[2]).to receive(:total_quantity).and_return(20)
      allow(subject).to receive(:jobs).and_return(jobs)
    end

    it 'returns the sum of all line item quantities from the artwork requests jobs' do
      expect(subject.total_quantity).to eq(30)
    end
  end

  describe '#ink_color_ids=', story_811: true do
    subject { build_stubbed(:artwork_request) }
    let!(:color_1) { create(:ink_color) }
    let!(:color_2) { create(:ink_color) }

    context 'when a given an id is a string instead of an integer' do
      it 'creates a custom ink color with that string as the name' do
        subject.ink_color_ids = [color_1.id, color_2.id, 'Other']
        expect(InkColor.where(custom: true, name: 'Other')).to exist
      end
    end
  end

  describe '#compatible_ink_colors', story_862: true, compatible_ink_colors: true do
    subject { build(:artwork_request, imprints: [imprint_1, imprint_2, imprint_3]).tap { |ar| ar.save(validate: false) } }

    let!(:red) { create(:ink_color, name: 'Red') }
    let!(:blue) { create(:ink_color, name: 'Blue') }
    let!(:yellow) { create(:ink_color, name: 'Yellow') }
    let!(:orange) { create(:ink_color, name: 'Orange') }
    let!(:purple) { create(:ink_color, name: 'Purple') }

    let!(:imprint_method_1) do
      create(
        :valid_imprint_method,
        ink_colors: [red, blue, yellow],
        print_locations: [create(:valid_imprint).print_location]
      )
    end

    let!(:imprint_method_2) do
      create(
        :valid_imprint_method,
        ink_colors: [red, blue, orange],
        print_locations: [create(:valid_imprint).print_location]
      )
    end

    let!(:imprint_method_3) do
      create(
        :valid_imprint_method,
        ink_colors: [red, blue, purple],
        print_locations: [create(:valid_imprint).print_location]
      )
    end

    let!(:imprint_1) { create(:valid_imprint, print_location: imprint_method_1.print_locations.first) }
    let!(:imprint_2) { create(:valid_imprint, print_location: imprint_method_2.print_locations.first) }
    let!(:imprint_3) { create(:valid_imprint, print_location: imprint_method_3.print_locations.first) }

    it 'returns the ink colors common to all associated imprint methods' do
      expect(subject.compatible_ink_colors.map(&:name)).to eq ['Red', 'Blue']
    end
  end

  describe '#has_proof_pending_approval?' do
    context 'artwork_request has at least one proof with status Emailed Customer' do
      it 'returns true'
    end

    context 'artwork_request has no proofs with status Emailed Customer' do
     it 'returns false'
    end
  end

  describe '#has_approved_proof?' do
    context 'artwork_request has at least one approved proof' do
      it 'returns true'
    end

    context 'artwork_request has no approved proofs' do
     it 'returns false'
    end
  end
end
