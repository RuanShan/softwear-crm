require 'spec_helper'

describe Imprint, imprint_spec: true do
  let(:job) { create :job }

  it { should be_paranoid }
  it { should belong_to :job }
  it { should belong_to :print_location }
  it { should have_one(:imprint_method).through(:print_location) }
  it { should validate_uniqueness_of(:print_location_id).scoped_to(:job_id) }
  it { should validate_presence_of :job }
  it { should validate_presence_of :print_location }
end
