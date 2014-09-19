require 'spec_helper'

describe 'jobs/_job.html.erb', job_spec: true do
  let(:job) { build_stubbed :job }

  describe 'imprints' do
    it 'contains a link to download a names/numbers csv' do
      render partial: 'jobs/job', locals: { job: job }

      expect(rendered).to have_css "a[href*='name_number']", text: 'Name/Number CSV'
    end
  end
end
