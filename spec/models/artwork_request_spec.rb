require 'spec_helper'
include ApplicationHelper

describe ArtworkRequest, artwork_request_spec: true do

  describe 'Validations' do
    it { should validate_presence_of(:deadline) }
    it { should validate_presence_of(:description) }
    it { should validate_presence_of(:imprint_method_id) }
    it { should validate_presence_of(:artwork_status) }
    it { should validate_presence_of(:print_location_id) }
    it { should validate_presence_of(:job_ids) }
    it { should validate_presence_of(:ink_color_ids) }
    it { should validate_presence_of(:artist_id) }
    it { should validate_presence_of(:salesperson_id) }
  end

  describe 'Relationships' do
    it { should belong_to(:artist) }
    it { should belong_to(:salesperson) }
    it { should belong_to(:imprint_method) }
    it { should belong_to(:print_location) }
    it { should have_and_belong_to_many(:jobs) }
    it { should have_and_belong_to_many(:ink_colors) }

  end

  context '#imprintable_variant_count' do
     before do
       jobs = [build_stubbed(:blank_job), build_stubbed(:blank_job), build_stubbed(:blank_job)]
       allow(jobs[0]).to receive(:imprintable_variant_count).and_return(10)
       allow(jobs[1]).to receive(:imprintable_variant_count).and_return(0)
       allow(jobs[2]).to receive(:imprintable_variant_count).and_return(20)
       allow(subject).to receive(:jobs).and_return(jobs)
     end

    it 'should return the sum of all line item quantities from the artwork requests jobs where imprintable_id is not null' do
      expect(subject.imprintable_variant_count).to eq(30)
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

    it 'should return all of the information for the imprintables ' do
      expect(subject.imprintable_info).to eq('Imprintable Info 2001, More Imprintable Info 1998, Imprintable Info 2005, Imprintable Info 2009')
    end
  end

end