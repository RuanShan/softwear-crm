require 'spec_helper'

describe 'jobs/_job.html.erb', job_spec: true do
  let(:job) { build_stubbed :job }

  describe 'imprints' do
    it 'displays a "download name/numbers" button to the right of the "Imprints" h4' do
      render partial: 'jobs/job', locals: { job: job }

      expect(rendered).to have_css "a[href*='names_numbers']", text: 'Download Names/Numbers CSV'
    end
  end
end
