require 'spec_helper'

describe 'imprints/_name_number_fields.html.erb', imprint_spec: true do
  let!(:order) { create(:order_with_job) }
  let(:job) { order.jobs.first }

  let(:imprint) { create :valid_imprint }

  it 'renders a text field for name_number.name and name_number.number' do
    render partial: 'imprints/name_number_fields', locals: { imprint: imprint }
    expect(rendered).to have_css 'input[type="text"][name*="name_number[name]"]'
    expect(rendered).to have_css 'input[type="number"][name*="name_number[number]"]'
  end
end