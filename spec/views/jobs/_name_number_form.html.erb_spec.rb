require 'spec_helper'

describe 'jobs/_name_number_form.html.erb', job_spec: true, name_number_spec: true, story_190: true do
  let!(:order) { create(:order_with_job) }
  let(:job) { order.jobs.first }

  let(:imprint) { create :valid_imprint }

  it 'renders a select box for the associated imprint, imprintable variant,
      and text field for name and number' do
    render 'jobs/name_number_form', job: job
    expect(rendered).to have_css 'select.js-name-number-imprint-select'
    expect(rendered).to have_css 'select.js-name-number-imprintable-select'
    expect(rendered).to have_css 'input[type="text"].js-name-field'
    expect(rendered).to have_css 'input[type="text"].js-number-field'
  end
end
