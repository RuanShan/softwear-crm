require 'spec_helper'
include ApplicationHelper

describe NameNumbersController, js: true, name_number_spec: true, story_190: true do
  let!(:valid_user) { create :alternate_user }
  let!(:job) { create :job }

  before(:each) do
    sign_in valid_user
    expect(Job).to receive(:find).and_return(build_stubbed(:job))
  end

  describe 'POST create' do
    context 'when failing' do
      it 'sets an error variable to be flashed later' do
        post :create, { job_id: job.id, format: 'js' }
        expect(assigns(:error)).to include("Errors")
      end
    end

    context 'when successful' do
      it 'responds with javascript' do
        post :create, {
          job_id: job.id, format: 'js', imprint_id: 1, imprintable_variant_id: 1,
          name: 'Test', Number: '222'
        }
        expect(response.content_type).to eq('text/javascript')
      end
    end
  end

  describe 'GET destroy' do
    let!(:name_number) { create(:name_number) }
    it 'responds with javascript' do
      get :destroy, { format: 'js', id: name_number.id }
      expect(response.content_type).to eq('text/javascript')
    end
  end
end
