require 'spec_helper'
include LineItemHelpers

describe Job, job_spec: true do
  subject { build_stubbed :blank_job }

  it { is_expected.to be_paranoid }
  it { is_expected.to accept_nested_attributes_for :line_items }

  it 'is not deletable when it has line items', line_item_spec: true do
    job = create(:job)
    _line_item = create(
      :non_imprintable_line_item,
      line_itemable_id: job.id, line_itemable_type: 'Job'
    )

    job.destroy
    expect(job.destroyed?).to_not be_truthy
    expect(job.errors.messages[:deletion_status])
      .to include 'All line items must be manually removed before a job can be deleted'
  end

  describe 'Relationships' do
    it { is_expected.to belong_to(:jobbable) }
    it { is_expected.to have_many(:imprints) }
    it { is_expected.to have_many(:line_items) }
    it { is_expected.to have_many(:artwork_requests) }

    context 'Tiered line items', story_570: true do
      subject { create(:job) }

      context 'good_line_items' do
        before do
          subject.line_items << create(:imprintable_line_item, tier: Imprintable::TIER.good)
          subject.line_items << create(:imprintable_line_item, tier: Imprintable::TIER.better)
          subject.line_items << create(:imprintable_line_item, tier: Imprintable::TIER.best)
        end

        it 'contains only "good" tiered line items' do
          expect(subject.good_line_items.size).to eq 1
          expect(subject.good_line_items.first.tier).to eq Imprintable::TIER.good
        end
      end

      context 'better_line_items' do
        before do
          subject.line_items << create(:imprintable_line_item, tier: Imprintable::TIER.better)
          subject.line_items << create(:imprintable_line_item, tier: Imprintable::TIER.good)
          subject.line_items << create(:imprintable_line_item, tier: Imprintable::TIER.best)
        end

        it 'contains only "better" tiered line items' do
          expect(subject.better_line_items.size).to eq 1
          expect(subject.better_line_items.first.tier).to eq Imprintable::TIER.better
        end
      end
    end
  end

  describe 'Validations' do
    # It won't listen to a multi-faceted scope
    # it { is_expected.to validate_uniqueness_of(:name).scoped_to(:order_id) }
  end

  describe 'When jobbable is quote' do
    let!(:line_item) { create(:imprintable_line_item) }
    let!(:imprint) { create(:valid_imprint) }
    subject { create(:job, line_items: [line_item], imprints: [imprint]) }
    let!(:quote) { create(:valid_quote, jobs: [subject]) }

    it 'destroys itself when rid of all line items and imprints', job_suicide: true do
      expect(subject.line_items).to_not be_empty
      subject.line_items.destroy_all
      expect(subject.line_items).to be_empty

      expect(Job.where(id: subject.id)).to exist

      expect(subject.imprints).to_not be_empty
      subject.imprints.destroy_all
      expect(subject.imprints).to be_empty

      expect(Job.where(id: subject.id)).to exist

      subject.save

      expect(Job.where(id: subject.id)).to_not exist
    end
  end

  describe '#duplicate!', story_959: true do
    let(:prod_job) { create(:production_job) }
    let!(:order) { create(:order_with_job) }
    let(:job) { order.jobs.first }
    let!(:line_item_1) { create(:imprintable_line_item, line_itemable: job, quantity: 2) }
    let!(:line_item_2) { create(:non_imprintable_line_item, line_itemable: job, quantity: 5) }
    let!(:imprint) { create(:valid_imprint) }

    before do
      job.line_items = [line_item_1, line_item_2]
      job.imprints = [imprint]
      job.save!
    end

    subject { job.reload.duplicate!.reload }

    it 'returns a new job (within its jobbable) with the same attributes and line items (with 0 quantity)' do
      expect(subject.jobbable).to eq order
      expect(subject.description).to eq job.description

      expect(subject.line_items.map(&:name)).to eq [line_item_1.name, line_item_2.name]
      expect(subject.line_items.map(&:id)).to_not eq [line_item_1.id, line_item_2.id]
      expect(subject.line_items.map(&:quantity)).to eq [0, line_item_2.quantity]

      expect(subject.imprints.first.name).to eq imprint.name
      expect(subject.imprints.first.id).to_not eq imprint.id
    end

    it 'does not duplicate softwear_prod_id' do
      job.update_column :softwear_prod_id, prod_job.id

      expect(subject.softwear_prod_id).to be_nil
      expect(subject.imprints.first.softwear_prod_id).to eq nil
    end
  end

  describe 'an fba job' do
    let!(:screen_print) { create(:valid_imprint_method, name: 'Screen Print') }
    let!(:full_chest) { create(:print_location, name: 'Full Chest', imprint_method: screen_print) }
    let!(:order) { create(:fba_order) }

    it 'has a default imprint of screen print full chest', story_967: true do
      job = Job.create(
        jobbable: order,
        name: 'Job one',
        description: 'Test spec job'
      )

      expect(job).to be_fba
      expect(job.imprints).to_not be_empty
    end
  end

  describe '#imprintable_info', artwork_request_spec: true do
    [:red, :green].each { |c| let!(c) { build_stubbed(:valid_color, name: c) } }
    [:shirt, :hat].each { |s| let!(s) { build_stubbed(:valid_imprintable) } }

    make_stubbed_variants :green, :shirt, [:S, :M, :L]
    make_stubbed_variants :red,   :hat,   [:OSFA]

    before(:each) do
      stub_imprintable_line_items with: green_shirt_items + red_hat_items
    end

    it 'should return all of the information for the imprintables ' do
      expect(subject.imprintable_info).to eq(
        "green #{shirt.style_name} #{shirt.style_catalog_no}, red #{hat.style_name} #{hat.style_catalog_no}"
      )
    end
  end

  describe '#imprintable_variant_count', artwork_request_spec: true do
    before do
      allow(subject).to receive(:line_items) { [
        build_stubbed(
          :blank_line_item, imprintable_object_id: 1, quantity: 25,
          imprintable_object_type: 'ImprintableVariant'
        ),
        build_stubbed(:blank_line_item, imprintable_object_id: nil, quantity: 50),
        build_stubbed(
          :blank_line_item, imprintable_object_id: 2, quantity: 30,
          imprintable_object_type: 'ImprintableVariant'
        )
      ]}
    end

    it 'should return the sum of all line item quantities where imprintable_id is not null' do
      expect(subject.imprintable_variant_count).to eq(55)
    end
  end

  context '#imprintable_variant_count with job having no imprintable line items (bug #176)', artwork_request_spec: true do
    before do
      allow(subject).to receive(:line_items) {[
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

  describe '#max_print_area', artwork_request_spec: true do
    let!(:job) { build_stubbed(:blank_job) }
    let!(:stub_imprintables) do
      [
        build_stubbed(
          :blank_imprintable,
          max_imprint_width: 5.5, max_imprint_height: 5.5
        )
      ]
    end

    before do
      allow(job).to receive(:imprintables).and_return stub_imprintables
    end

    let!(:print_location) { build_stubbed :blank_print_location, name: 'Chest' }

    context 'print_location constricts both width and height' do
      before do
        print_location.max_width  = 3.1
        print_location.max_height = 2.6
      end

      it 'should return the max print area' do
        expect(job.max_print_area(print_location)).to eq([3.1, 2.6])
      end
    end

    context 'print_location constricts just width' do
      before do
        print_location.max_width  = 3.1
        print_location.max_height = 8.6
      end

      it 'should return the max print area' do
        expect(job.max_print_area(print_location)).to eq([3.1, 5.5])
      end
    end

    context 'print_location constricts just height' do
      before do
        print_location.max_width  = 9.1
        print_location.max_height = 2.6
      end

      it 'should return the max print area' do
        expect(job.max_print_area(print_location)).to eq([5.5, 2.6])
      end
    end

    context 'print_location constricts neither width or height' do
      before do
        print_location.max_width  = 9.1
        print_location.max_height = 8.6
      end

      it 'should return the max print area' do
        expect(job.max_print_area(print_location)).to eq([5.5, 5.5])
      end
    end
  end

  context '#sort_line_items', line_item_spec: true, sort_line_items: true do
    let!(:job) { build_stubbed(:job) }
    [:red, :blue, :green]
      .each { |c| let!(c) { build_stubbed(:valid_color, name: c) } }
    [:shirt, :hat].each { |s| let!(s) { build_stubbed(:valid_imprintable) } }

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
      stub_imprintable_line_items with: line_items
    end

    it 'organizes the line items by imprintable, then color' do
      result = job.sort_line_items

      expect(result.keys).to include shirt.name
      expect(result.keys).to include hat.name

      result[shirt.name].keys.tap do |it|
        expect(it).to include "green"
        expect(it).to include "red"
        expect(it).to_not include "blue"
      end

      result[hat.name].keys.tap do |it|
        expect(it).to include "red"
        expect(it).to include "blue"
        expect(it).to_not include "green"
      end

      result[shirt.name]["green"].tap do |it|
        expect(it).to include green_shirt_s_item
        expect(it).to include green_shirt_m_item
        expect(it).to include green_shirt_l_item
      end

      result[hat.name]["blue"].tap do |it|
        expect(it).to eq [blue_hat_osfa_item]
      end
    end

    it 'sorts the resulting arrays by size' do
      sizes = [size_xl, size_m, size_s]
      sizes.first.sort_order = 3
      sizes[1].sort_order = 2
      sizes[2].sort_order = 1

      result = job.sort_line_items

      expect(result[shirt.name]["red"])
        .to eq [red_shirt_s_item, red_shirt_m_item, red_shirt_xl_item]
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

  context 'when jobs are inside orders' do
    it 'subsequent jobs created with a nil name will be named "New Job #"' do
      order = create(:order)
      job0 = create(:blank_job, jobbable: order)
      job1 = create(:blank_job, jobbable: order)
      job2 = create(:blank_job, jobbable: order)
      expect(job0.name).to eq 'New Job'
      expect(job1.name).to eq 'New Job 2'
      expect(job2.name).to eq 'New Job 3'
    end

    it "deleting a job doesn't stop subsequent job name generation from working" do
      order = create(:order)
      job = create(:blank_job, jobbable: order)
      job.destroy

      job0 = create(:blank_job, jobbable: order)
      job1 = create(:blank_job, jobbable: order)
      job2 = create(:blank_job, jobbable: order)
      expect(job0.name).to eq 'New Job'
      expect(job1.name).to eq 'New Job 2'
      expect(job2.name).to eq 'New Job 3'
    end

    context 'that are fba' do
      it 'sets the placeholder to "Shipping Location"' do
        order = create(:fba_order)
        job = create(:blank_job, jobbable: order)
        expect(job.name).to eq 'Shipping Location'
      end
    end
  end
end
