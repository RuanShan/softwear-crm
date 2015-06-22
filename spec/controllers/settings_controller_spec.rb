require 'spec_helper'
include ApplicationHelper

describe SettingsController, setting_spec: true do
  let!(:valid_user) { create :alternate_user }

  before(:each) { sign_in valid_user }

  describe 'GET edit' do
    it 'calls get_freshdesk_settings' do
      fd_url   = Setting.create name: 'freshdesk_url', val: '123'
      fd_email = Setting.create name: 'freshdesk_email', val: '123'
      fd_pass = Setting.create name: 'freshdesk_password', val: '123'
      fd_api = Setting.create name: 'insightly_api_key', val: '123'

      get :edit
      expect(assigns[:freshdesk_settings]).to eq(
        url: fd_url,
        email: fd_email,
        password: fd_pass
      )
      expect(assigns[:insightly_settings]).to eq(
        api_key: fd_api
      )
    end
  end

  describe 'PUT update' do
    it 'calls update' do
      expect(Setting).to receive(:update).and_return(nil).twice
      expect(post :update, fd_settings: {}, in_settings: {}).to redirect_to integrated_crms_path
    end
  end
end
