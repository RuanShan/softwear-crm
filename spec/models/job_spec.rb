require 'spec_helper'
include LineItemHelpers

describe Job, job_spec: true do
  it { should validate_presence_of :name }
  it { should validate_uniqueness_of(:name).scoped_to(:order_id) }

  it 'should allow two jobs with the same name if one is deleted' do
    job1 = create(:job, name: 'Job Name')
    job1.destroy

    job2 = create(:job, name: 'Job Name')
    expect(job2).to be_valid
  end

  it 'should have many line items' do
    job = create(:job, name: 'job')
    expect(job.line_items).to be_a ActiveRecord::Relation # I think
  end

  context '#sort_line_items', donow: true do
    let!(:job) { create(:job) }
    [:red, :blue, :green].each { |c| let!(c) { create(:valid_color, name: c) } }
    [:shirt, :hat].each { |s| let!(s) { create(:valid_imprintable) } }
    make_variants :green, :shirt, [:S, :M, :L]
    make_variants :red,   :shirt, [:S, :M, :XL]
    make_variants :red,   :hat,   [:OSFA]
    make_variants :blue,  :hat,   [:OSFA]

    it 'will sort out the line items for the job' do
      result = job.sort_line_items

      expect(result.keys).to include :shirt
      expect(result.keys).to include :hat

      with(result[:shirt].keys) do |it|
        expect(it).to include :green
        expect(it).to include :red
        expect(it).to_not include :blue
      end

      with(result[:hat].keys) do |it|
        expect(it).to include :red
        expect(it).to include :blue
        expect(it).to_not include :green
      end

      with(result[:shirt][:green].keys) do |it|
        expect(it).to include :S
        expect(it).to include :M
        expect(it).to include :L
        expect(it).to_not include :XL
      end

      with(result[:hat][:blue].keys) do |it|
        expect(it).to eq [:OSFA]
      end

      expect(result[:shirt][:red][:M]).to eq red_shirt_m_item
      expect(result[:hat][:blue][:OSFA]).to eq blue_hat_osfa_item
    end
  end
end