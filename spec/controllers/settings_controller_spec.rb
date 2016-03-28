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
      production_crm_endpoint = Setting.create name: 'softwear_production_endpoint', val: '123'
      production_crm_email= Setting.create name: 'softwear_production_email', val: '123'
      production_crm_token = Setting.create name: 'softwear_production_token', val: '123'
      payflow_login = Setting.create name: 'payflow_login', val: 'me'
      payflow_password = Setting.create name: 'payflow_password', val: 'okokok'
      paypal_username = Setting.create name: 'paypal_username', val: 'pypalsir'
      paypal_password = Setting.create name: 'paypal_password', val: 'pppass'
      paypal_signature = Setting.create name: 'paypal_signature', val: 'ppsig'
      payment_logo_url = Setting.create name: 'payment_logo_url', val: 'http://pic.png'

      get :edit
      expect(assigns[:freshdesk_settings]).to eq(
        url: fd_url,
        email: fd_email,
        password: fd_pass
      )
      expect(assigns[:insightly_settings]).to eq(
        api_key: fd_api
      )
      expect(assigns[:production_crm_settings]).to eq(
        endpoint: production_crm_endpoint,
        email: production_crm_email,
        token: production_crm_token
      )
      expect(assigns[:payflow_settings]).to eq(
        login: payflow_login,
        password: payflow_password
      )
      expect(assigns[:paypal_settings]).to eq(
        username: paypal_username,
        password: paypal_password,
        signature: paypal_signature,
        logo_url: payment_logo_url
      )
    end
  end

  describe 'PUT update' do
    it 'calls update' do
      expect(Setting).to receive(:update).and_return(nil).exactly(5).times
      expect(post :update, fd_settings: {}, in_settings: {}, production_crm_settings: {}, payflow_settings: {}, paypal_settings: {}, sales_tax_settings: {}).to redirect_to integrated_crms_path
    end
  end
end
