class EmailTemplatesController < InheritedResources::Base
  before_action :set_current_action

  protected

  def set_current_action
    @current_action = 'email_templates'
  end

  def permitted_params
    params.permit(email_template: %i(subject from cc bcc body template_type name))
  end
end
