class SettingsController < InheritedResources::Base
  before_action :set_current_action

  def edit
    @freshdesk_settings = Setting.get_freshdesk_settings
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
