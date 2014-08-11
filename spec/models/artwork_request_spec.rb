require 'spec_helper'
include ApplicationHelper

describe ArtworkRequest, artwork_requests_spec: true do

  it { is_expected.to be_paranoid }

  describe 'Relationships' do
    it { is_expected.to belong_to(:artist) }
    it { is_expected.to belong_to(:imprint_method) }
    it { is_expected.to belong_to(:print_location) }
    it { is_expected.to belong_to(:salesperson) }
    it { is_expected.to have_many(:assets) }
    it { is_expected.to have_and_belong_to_many(:artworks) }
    it { is_expected.to have_and_belong_to_many(:ink_colors) }
    it { is_expected.to have_and_belong_to_many(:jobs) }
    it { is_expected.to accept_nested_attributes_for(:assets)}
  end

  describe 'Validations' do
    it { is_expected.to validate_presence_of(:artist) }
    it { is_expected.to validate_presence_of(:artwork_status) }
    it { is_expected.to validate_presence_of(:deadline) }
    it { is_expected.to validate_presence_of(:description) }
    it { is_expected.to validate_presence_of(:imprint_method) }
    it { is_expected.to validate_presence_of(:ink_colors) }
    it { is_expected.to validate_presence_of(:jobs) }
    it { is_expected.to validate_presence_of(:priority) }
    it { is_expected.to validate_presence_of(:print_location) }
    it { is_expected.to validate_presence_of(:salesperson) }
  end

  context '#imprintable_variant_count' do
     before do
       jobs = [build_stubbed(:blank_job), build_stubbed(:blank_job), build_stubbed(:blank_job)]
       allow(jobs[0]).to receive(:imprintable_variant_count).and_return(10)
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
        allow(job[0]).to receive(:imprintable_variant_count).and_return(0)
        allow(subject).to receive(:jobs).and_return(job)
      end

    it 'returns zero' do
      expect(subject.imprintable_variant_count).to eq(0)
    end
  end

  context '#imprintable_info' do
    before do
      jobs = [build_stubbed(:blank_job), build_stubbed(:blank_job), build_stubbed(:blank_job)]
      allow(jobs[0]).to receive(:imprintable_info).and_return('Imprintable Info 2001, More Imprintable Info 1998')
      allow(jobs[1]).to receive(:imprintable_info).and_return('Imprintable Info 2005')
      allow(jobs[2]).to receive(:imprintable_info).and_return('Imprintable Info 2009')
      allow(subject).to receive(:jobs).and_return(jobs)
    end

    it 'returns all of the information for the imprintables joined by commas' do
      expect(subject.imprintable_info).to eq('Imprintable Info 2001, More Imprintable Info 1998, Imprintable Info 2005, Imprintable Info 2009')
    end
  end

  context '#max_print_area' do
    let!(:print_location) { create(:blank_print_location, name: 'Chest', max_width: 9.1, max_height: 2.6) }
    before do
      jobs = [build_stubbed(:blank_job), build_stubbed(:blank_job), build_stubbed(:blank_job), build_stubbed(:blank_job)]
      allow(jobs[0]).to receive(:max_print_area).and_return([3.1, 2.6])
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
      allow(jobs[0]).to receive(:total_quantity).and_return(10)
      allow(jobs[1]).to receive(:total_quantity).and_return(0)
      allow(jobs[2]).to receive(:total_quantity).and_return(20)
      allow(subject).to receive(:jobs).and_return(jobs)
    end

    it 'returns the sum of all line item quantities from the artwork requests jobs' do
      expect(subject.total_quantity).to eq(30)
    end
  end
end
