require 'spec_helper'

describe 'imprints/_name_number_fields.html.erb', imprint_spec: true do
  let!(:order) { create(:order_with_job) }
  let(:job) { order.jobs.first }

  let(:imprint) { create :valid_imprint }

  it 'renders a text field for name_number.name and name_number.number', story_189: true do
    render 'imprints/name_number_fields', imprint: imprint, imprint_method_name: 'IM_name'
    expect(rendered).to have_css 'input[type="text"].js-name-format-field'
    expect(rendered).to have_css 'input[type="text"].js-number-format-field'
  end
end
