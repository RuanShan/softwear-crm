class SettingsController < InheritedResources::Base
  before_action :set_current_action

  def edit
    @freshdesk_settings = {
        freshdesk_url: Setting.find_by(name: 'freshdesk_url'),
        freshdesk_email: Setting.find_by(name: 'freshdesk_email'),
        freshdesk_password: Setting.find_by(name: 'freshdesk_password')
    }
  end

  def update
    Setting.update(params[:fd_settings].keys, params[:fd_settings].values)
    redirect_to integrated_crms_path
  end

private

  def set_current_action
    @current_action = 'settings'
  end
end
