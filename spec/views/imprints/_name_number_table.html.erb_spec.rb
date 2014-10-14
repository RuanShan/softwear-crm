require 'spec_helper'

describe 'imprints/_name_number_table.html.erb', imprint_spec: true, name_number_spec: true, story_190: true do
  let!(:order) { create(:order_with_job) }
  let(:job) { order.jobs.first }

  let(:imprint) { create :valid_imprint }

  it 'contains a table with the appropriate headers' do
    render 'imprints/name_number_table'
    expect(rendered).to have_selector('th', text: 'Imprintable Variant')
    expect(rendered).to have_selector('th', text: 'Name')
    expect(rendered).to have_selector('th', text: 'Number')
  end

  context 'when populated with a valid name/number' do

    it 'displays the proper information, as well as a delete button' do
      render 'imprints/name_number_table'
      expect(rendered).to have_text 'imprintable name'
      expect(rendered).to have_text 'name'
      expect(rendered).to have_text 'number'
      expect(rendered).to have_selector('delete-box-selector')
    end
  end
end
