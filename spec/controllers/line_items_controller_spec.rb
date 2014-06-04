require 'spec_helper'

describe LineItemsController, line_item_spec: true, donow: true do
  describe '#new' do
    let!(:job) { create :job }
    before(:each) do
      get :new, job_id: job.id
    end

    it 'should succeed' do
      expect(response).to render_template :new
    end
  end

  
end