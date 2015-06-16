require 'spec_helper'

describe 'quotes/show/_line_items_informal.html.erb_spec.rb', quote_spec: true do
  let!(:quote) { build_stubbed(:valid_quote, jobs: jobs) }
  let!(:jobs) {
    [
        build_stubbed(
          :blank_job,
          jobbable_type: 'Quote',
          name: 'Name Hurr',
          description: 'So descriptive'
        )
    ]
  }

  before(:each) do
    allow(quote).to receive(:imprintable_jobs).and_return jobs
    render 'quotes/show/line_items_informal', quote: quote
  end

  it 'has a div for each job, and each div has the job name and description' do
    expect(rendered).to have_css('.informal-job', count: jobs.count)
    quote.jobs.each do |job|
      expect(rendered).to have_content(job.name)
      expect(rendered).to have_content(job.description)
    end
  end



end
