require 'spec_helper'

describe JobsController, job_spec: true do
  render_views
  
  let!(:valid_user) { create :alternate_user }
  before(:each) { sign_in valid_user }
  let(:job) { create(:job) }

  describe '#destroy' do
    context 'when the job has line items' do
      let!(:line_item) { create(:non_imprintable_line_item, job_id: job.id) }
      it 'should return json with response.result == "failure"' do
        delete :destroy, id: job.id
        jsonResponse = JSON.parse response.body
        expect(jsonResponse['result']).to eq 'failure'
      end
    end
    context 'when the job has no line items' do
      it 'should return json with response.result == "success"' do
        delete :destroy, id: job.id
        jsonResponse = JSON.parse response.body
        expect(jsonResponse['result']).to eq 'success'
      end
    end
  end
end