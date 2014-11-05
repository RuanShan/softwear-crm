require 'spec_helper'
include ApplicationHelper

describe SalesReportsController, story_82: true, sales_report_spec: true do
  let!(:valid_user) { create :alternate_user }
  before(:each) { sign_in valid_user }

  describe 'GET index' do
    it 'assigns reports instance variable' do
      get :index
      expect(assigns(:reports)).to eq Report::SALES_REPORTS
    end
  end

  describe 'GET show' do
    it 'assigns a new report and calls get_data' do
      expect(subject).to receive(:get_data)
      expect(Report).to receive(:new)
      get :show, start_time: '2014-10-2', end_time: '2014-11-20', report_type: 'quote_request_success'
    end
  end

  describe 'POST create' do
    it 'redirects', new: true do
      expect(false).to be_truthy
    end
  end
end