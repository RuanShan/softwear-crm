class EmailTemplatesController < InheritedResources::Base
  before_action :set_current_action

  def create
    create! do |success, failure|
      success.html do
        flash[:notice] = 'Your new email template was successfully created.'
        redirect_to email_templates_path
      end
      failure.html { render :new }
    end
  end

  def update
    update! do |success, failure|
      success.html do
        flash[:notice] = 'Email template was successfully updated.'
        redirect_to email_templates_path
      end
      failure.html { render :edit }
    end
  end

private

  def set_current_action
    @current_action = 'email_templates'
  end

  def permitted_params
    params.permit(email_template: %i(subject from cc bcc body))
  end
end
