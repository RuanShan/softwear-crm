require 'spec_helper'
include ApplicationHelper

describe SettingsController, setting_spec: true do
  let!(:valid_user) { create :alternate_user }

  before(:each) { sign_in valid_user }

  describe 'GET edit' do
    it 'calls get_freshdesk_settings' do
      expect(Setting).to receive(:get_freshdesk_settings).and_return(5)
      get :edit
      expect(assigns[:freshdesk_settings]).to eq(5)
    end
  end

  describe 'PUT update' do
    it 'calls update' do
      expect(Setting).to receive(:update).and_return(nil)
      expect(post :update, fd_settings: {}).to redirect_to integrated_crms_path
    end
  end
end
