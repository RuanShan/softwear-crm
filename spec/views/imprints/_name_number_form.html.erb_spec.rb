require 'spec_helper'

describe 'imprints/_name_number_form.html.erb', imprint_spec: true, name_number_spec: true, story_190: true do
  let!(:order) { create(:order_with_job) }
  let(:job) { order.jobs.first }

  let(:imprint) { create :valid_imprint }

  it 'renders a select box for the associated imprintable variants,
      text field for name, and number field for number' do
    render 'imprints/name_number_form'
    expect(rendered).to have_css 'input[type="text"].js-name-field'
    expect(rendered).to have_css 'input[type="number"].js-number-field'
    expect(rendered).to have_css 'select.js-variant-select'
  end
end
