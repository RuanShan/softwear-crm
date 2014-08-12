require 'spec_helper'

describe ImprintsController, imprint_spec: true do
  let(:print_location) { create :print_location }
  let(:job) { create :job }
  let(:imprint) { create :imprint, 
                          print_location_id: print_location.id,
                          job_id: job.id }

  it_can 'batch update'
end