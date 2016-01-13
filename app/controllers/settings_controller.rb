class SettingsController < InheritedResources::Base
  before_filter :sales_manager_only
  before_action :set_current_action

  def edit
    @freshdesk_settings = {
      url:      Setting.find_or_create_by(name: 'freshdesk_url'),
      email:    Setting.find_or_create_by(name: 'freshdesk_email'),
      password: Setting.find_or_create_by(name: 'freshdesk_password')
    }
    @insightly_settings = {
      api_key: Setting.find_or_create_by(name: 'insightly_api_key')
    }
    @production_crm_settings = {
     endpoint: Setting.find_or_create_by(name: 'softwear_production_endpoint'),
     email: Setting.find_or_create_by(name: 'softwear_production_email'),
     token: Setting.find_or_create_by(name: 'softwear_production_token')
    }
    @payflow_settings = {
     login:    Setting.find_or_create_by(name: 'payflow_login'),
     password: Setting.find_or_create_by(name: 'payflow_password')
    }
    @paypal_settings = {
     username:  Setting.find_or_create_by(name: 'paypal_username'),
     password:  Setting.find_or_create_by(name: 'paypal_password'),
     signature: Setting.find_or_create_by(name: 'paypal_signature'),
     logo_url:  Setting.find_or_create_by(name: 'payment_logo_url')
    }
  end

  def update
    Setting.update(params[:fd_settings].keys, params[:fd_settings].values)
    Setting.update(params[:in_settings].keys, params[:in_settings].values)
    Setting.update(params[:production_crm_settings].keys, params[:production_crm_settings].values)
    Setting.update(params[:payflow_settings].keys, params[:payflow_settings].values)
    Setting.update(params[:paypal_settings].keys, params[:paypal_settings].values)
    redirect_to integrated_crms_path
  end

  private

  def set_current_action
    @current_action = 'settings'
  end
end
