class SettingsController < InheritedResources::Base
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
  end

  def update
    Setting.update(params[:fd_settings].keys, params[:fd_settings].values)
    Setting.update(params[:in_settings].keys, params[:in_settings].values)
    Setting.update(params[:production_crm_settings].keys, params[:production_crm_settings].values)
    redirect_to integrated_crms_path
  end

  private

  def set_current_action
    @current_action = 'settings'
  end
end
