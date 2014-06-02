require 'spec_helper'

describe Job, job_spec: true do
  it { should validate_presence_of :name }
  it { should validate_uniqueness_of(:name).scoped_to(:order_id) }

  it 'should allow two jobs with the same name if one is deleted' do
    job1 = create(:job, name: 'Job Name')
    job1.destroy

    job2 = create(:job, name: 'Job Name')
    expect(job2).to be_valid
  end

  it 'should have many line items' do
    job = create(:job, name: 'job')
    expect(job.line_items).to be_a ActiveRecord::Relation # I think
  end
end