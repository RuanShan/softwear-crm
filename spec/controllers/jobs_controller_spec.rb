require 'spec_helper'

describe JobsController, job_spec: true do
  render_views
  
  let!(:valid_user) { create :alternate_user }
  before(:each) { sign_in valid_user }
  let(:job) { create(:job) }

  describe '#destroy' do
    context 'when the job has line items' do
      let!(:line_item) do
        create(
          :non_imprintable_line_item,
          line_itemable_id: job.id,
          line_itemable_type: 'Job'
        )
      end
      it 'should return json with response.result == "failure"' do
        delete :destroy, id: job.id, format: :json
        jsonResponse = JSON.parse response.body
        expect(jsonResponse['result']).to eq 'failure'
      end
    end
    context 'when the job has no line items' do
      it 'should return json with response.result == "success"' do
        delete :destroy, id: job.id, format: :json
        jsonResponse = JSON.parse response.body
        expect(jsonResponse['result']).to eq 'success'
      end
    end
  end

  describe 'GET #name_number_csv' do
    it 'sends csv data' do
      allow(Job).to receive(:find).and_return job
      expect(job).to receive(:name_number_csv)

      get :name_number_csv, id: job.id
    end
  end
end