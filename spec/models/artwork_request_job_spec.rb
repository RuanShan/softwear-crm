require 'spec_helper'
include ApplicationHelper

describe ArtworkRequestJob, artwork_request_job_spec: true do

  it { is_expected.to be_paranoid }

  describe 'Relationships' do
    it { is_expected.to belong_to(:artwork_request) }
    it { is_expected.to belong_to(:job) }
  end

  describe 'Validations' do
    it { is_expected.to validate_uniqueness_of(:artwork_request_id).scoped_to(:job_id) }
  end
end