require 'spec_helper'

describe 'jobs/_name_number_table.html.erb', imprint_spec: true, name_number_spec: true, story_190: true do
  let!(:order) { create :order_with_job }
  let(:job) { order.jobs.first }

  let(:imprint) { create :valid_imprint }

  it 'contains a table with the appropriate headers' do
    render 'jobs/name_number_table', job: job
    expect(rendered).to have_selector('th', text: 'Imprint')
    expect(rendered).to have_selector('th', text: 'Imprintable')
    expect(rendered).to have_selector('th', text: 'Name')
    expect(rendered).to have_selector('th', text: 'Number')
    expect(rendered).to have_selector('th', text: 'Destroy')
  end

  context 'when populated with a valid name/number' do
    let!(:name_number) { create(:name_number) }
    it 'displays the proper information, as well as a delete button' do
      expect_any_instance_of(Job).to receive_message_chain(:name_number_imprints, :flat_map).and_return([name_number])
      expect_any_instance_of(Imprint).to receive(:name).and_return('imprint name')
      expect_any_instance_of(ImprintableVariant).to receive(:full_name).and_return('imprintable name')

      render 'jobs/name_number_table', job: job

      expect(rendered).to have_text 'imprint name'
      expect(rendered).to have_text 'imprintable name'
      expect(rendered).to have_text 'Test Name'
      expect(rendered).to have_text '33'
      expect(rendered).to have_selector('i.fa.danger.fa-times-circle')
    end
  end
end
