require 'spec_helper'
include LineItemHelpers

describe Job, job_spec: true do

  it { is_expected.to be_paranoid }

  it 'is not deletable when it has line items', line_item_spec: true do
    job = create(:job)
    _line_item = create(:non_imprintable_line_item, line_itemable_id: job.id, line_itemable_type: 'Job')

    job.destroy
    expect(job.destroyed?).to_not be_truthy
    expect(job.errors.messages[:deletion_status]).to include 'All line items must be manually removed before a job can be deleted'
  end

  describe 'Relationships' do
    it { is_expected.to belong_to(:order) }
    it { is_expected.to have_many(:colors).through(:imprintable_variants) }
    it { is_expected.to have_many(:imprints) }
    it { is_expected.to have_many(:imprintables).through(:imprintable_variants) }
    it { is_expected.to have_many(:imprintable_variants).through(:line_items) }
    it { is_expected.to have_many(:line_items) }
    it { is_expected.to have_and_belong_to_many(:artwork_requests) }
  end

  describe 'Validations' do
    it { is_expected.to validate_uniqueness_of(:name).scoped_to(:order_id) }
  end

  describe '#imprintable_info', artwork_request_spec: true do
    let!(:job) { create(:job) }
    [:red, :green].each { |c| let!(c) { create(:valid_color, name: c) } }
    [:shirt, :hat].each { |s| let!(s) { create(:valid_imprintable) } }

    make_variants :green, :shirt, [:S, :M, :L]
    make_variants :red,   :hat,   [:OSFA]

    it 'should return all of the information for the imprintables ' do
      expect(job.imprintable_info).to eq("green #{shirt.style_name} #{shirt.style_catalog_no}, red #{hat.style_name} #{hat.style_catalog_no}")
    end
  end

  describe '#imprintable_variant_count', artwork_request_spec: true do
    before do
      allow(subject).to receive(:line_items) { [
          build_stubbed(:blank_line_item, imprintable_variant_id: 1, quantity: 25),
          build_stubbed(:blank_line_item, imprintable_variant_id: nil, quantity: 50),
          build_stubbed(:blank_line_item, imprintable_variant_id: 1, quantity: 30)
      ]}
    end

    it 'should return the sum of all line item quantities where imprintable_id is not null' do
      expect(subject.imprintable_variant_count).to eq(55)
    end
  end

  context '#imprintable_variant_count with job having no imprintable line items (bug #176)', artwork_request_spec: true do
    before do
      allow(subject).to receive(:line_items) { [
          build_stubbed(:blank_line_item, imprintable_variant_id: nil, quantity: 5)
      ]}
    end

    it 'should return the sum of all line item quantities where imprintable_id is not null' do
      expect(subject.imprintable_variant_count).to eq(0)
    end
  end

  context '#imprintable_variant_count with job having no line items (bug #176)', artwork_request_spec: true do
    let!(:job) { build_stubbed(:blank_job) }

    it 'should return the sum of all line item quantities where imprintable_id is not null' do
      expect(job.imprintable_variant_count).to eq(0)
    end
  end

  describe '#max_print_area', artwork_request_spec: true, wip: true do
    let!(:job){ build_stubbed(:blank_job) }

    before do
      allow(job).to receive(:imprintables).and_return([build_stubbed(:blank_imprintable, max_imprint_width: 5.5, max_imprint_height: 5.5)])
    end

    context 'print_location constricts both width and height' do
      let!(:print_location) { build_stubbed(:blank_print_location, name: 'Chest', max_width: 3.1, max_height: 2.6) }
      it 'should return the max print area' do
        expect(job.max_print_area(print_location)).to eq([3.1, 2.6])
      end
    end

    context 'print_location constricts just width' do
      let!(:print_location) { build_stubbed(:blank_print_location, name: 'Chest', max_width: 3.1, max_height: 8.6) }
      it 'should return the max print area' do
        expect(job.max_print_area(print_location)).to eq([3.1, 5.5])
      end
    end

    context 'print_location constricts just height' do
      let!(:print_location) { build_stubbed(:blank_print_location, name: 'Chest', max_width: 9.1, max_height: 2.6) }
      it 'should return the max print area' do
        expect(job.max_print_area(print_location)).to eq([5.5, 2.6])
      end
    end

    context 'print_location constricts neither width or height' do
      let!(:print_location) { build_stubbed(:blank_print_location, name: 'Chest', max_width: 9.1, max_height: 8.6) }
      it 'should return the max print area' do
        expect(job.max_print_area(print_location)).to eq([5.5, 5.5])
      end
    end
  end

  context '#sort_line_items', line_item_spec: true, sort_line_items: true do
    let!(:job) { create(:job) }
    [:red, :blue, :green].each { |c| let!(c) { create(:valid_color, name: c) } }
    [:shirt, :hat].each { |s| let!(s) { create(:valid_imprintable) } }

    make_stubbed_variants :green, :shirt, [:S, :M, :L]
    make_stubbed_variants :red,   :shirt, [:S, :M, :XL]
    make_stubbed_variants :red,   :hat,   [:OSFA]
    make_stubbed_variants :blue,  :hat,   [:OSFA]

    let(:line_items) do
      green_shirt_items +
      red_shirt_items +
      red_hat_items +
      blue_hat_items
    end

    before :each do
      allow(LineItem).to receive_message_chain(
        :includes, :where, :where, :not
      )
        .and_return line_items
    end

    it 'organizes the line items by imprintable, then color' do
      result = job.sort_line_items

      expect(result.keys).to include shirt.name
      expect(result.keys).to include hat.name

      result[shirt.name].keys.tap do |it|
        expect(it).to include :green
        expect(it).to include :red
        expect(it).to_not include :blue
      end

      result[hat.name].keys.tap do |it|
        expect(it).to include :red
        expect(it).to include :blue
        expect(it).to_not include :green
      end

      result[shirt.name][:green].tap do |it|
        expect(it).to include green_shirt_s_item
        expect(it).to include green_shirt_m_item
        expect(it).to include green_shirt_l_item
      end

      result[hat.name][:blue].tap do |it|
        expect(it).to eq [blue_hat_osfa_item]
      end
    end

    it 'sorts the resulting arrays by size' do
      sizes = [size_xl, size_m, size_s]
      sizes[0].sort_order = 3
      sizes[1].sort_order = 2
      sizes[2].sort_order = 1

      result = job.sort_line_items

      expect(result[shirt.name][:red])
        .to eq [red_shirt_s_item, red_shirt_m_item, red_shirt_xl_item]
    end

    it 'should eager load imprintable variant color and size' do
      expect(LineItem).to receive(:includes)
        .with(imprintable_variant: [:color, :size])
        .and_call_original

      job.sort_line_items
    end
  end

  context '#standard_line_items', line_item_spec: true do
    let!(:job) { create(:job) }

    let!(:white) { create(:valid_color, name: 'white') }
    let!(:shirt) { create(:valid_imprintable) }

    make_stubbed_variants :white, :shirt, [:S, :M, :L]

    let!(:standard0) { create :non_imprintable_line_item, line_itemable: job }
    let!(:standard1) { create :non_imprintable_line_item, line_itemable: job }

    subject { job.standard_line_items }

    it { is_expected.to include standard0 }
    it { is_expected.to include standard1 }

    %w(s m l).each do |size|
      it { is_expected.to_not include send("white_shirt_#{size}_item") }
    end
  end

  describe '#total_quantity', artwork_request_spec: true do
    before do
      allow(subject).to receive(:line_items) {[
          build_stubbed(:blank_line_item, quantity: 25),
          build_stubbed(:blank_line_item, quantity: 50),
          build_stubbed(:blank_line_item, quantity: 30)
      ]}
    end

    it 'returns the sum of all line item quantities' do
      expect(subject.total_quantity).to eq(105)
    end
  end

  it 'allows two jobs with the same name if one is deleted' do
    job1 = create(:job, name: 'Job Name')
    job1.destroy

    job2 = build(:job, name: 'Job Name')
    expect(job2).to be_valid
  end

  it 'subsequent jobs created with a nil name will be named "New Job #"' do
    job0 = create(:empty_job)
    job1 = create(:empty_job)
    job2 = create(:empty_job)
    expect(job0.name).to eq 'New Job'
    expect(job1.name).to eq 'New Job 2'
    expect(job2.name).to eq 'New Job 3'
  end

  it "deleting a job doesn't stop subsequent job name generation from working" do
    job = create(:empty_job)
    job.destroy

    job0 = create(:empty_job)
    job1 = create(:empty_job)
    job2 = create(:empty_job)
    expect(job0.name).to eq 'New Job'
    expect(job1.name).to eq 'New Job 2'
    expect(job2.name).to eq 'New Job 3'
  end
end
