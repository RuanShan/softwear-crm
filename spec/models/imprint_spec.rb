require 'spec_helper'

describe Imprint, imprint_spec: true do
  5.times do |n|
    let("print_location#{n+1}") { create(:print_location) }
  end
  2.times do |n|
    let("imprint_method#{n+1}") { create(:valid_imprint_method) }
  end
  let(:job) { create :job }

  it { should be_paranoid }
  it { should belong_to :job }
  it { should belong_to :print_location }
  it { should have_one(:imprint_method).through(:print_location) }
end
