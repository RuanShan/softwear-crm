require 'spec_helper'

describe Job, job_spec: true do
	it { should validate_presence_of :name }
	it { should validate_uniqueness_of(:name).scoped_to(:order_id) }
end