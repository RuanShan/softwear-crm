class SettingsController < InheritedResources::Base
  def edit
    @freshdesk_settings = Setting.get_freshdesk_settings
    render 'edit'
  end

  def update

  end

  def update_multiple
    Setting.update(params[:fd_settings].keys, params[:fd_settings].values)
    redirect_to integrated_crms_path
  end
end
