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
  end

  def update
    Setting.update(params[:fd_settings].keys, params[:fd_settings].values)
    Setting.update(params[:in_settings].keys, params[:in_settings].values)
    redirect_to integrated_crms_path
  end

  private

  def set_current_action
    @current_action = 'settings'
  end
end
