class EmailTemplatesController < InheritedResources::Base
  before_action :set_current_action

  def create
    super do |success, failure|
      success.html { redirect_to email_templates_path, notice: "Email Template '#{@email_template.name}' was created successfully"  }
      failure.html { render :edit }
    end
  end

  def update
    super do |success, failure|
      success.html { redirect_to email_templates_path, notice: "Email Template '#{@email_template.name}' was updated successfully" }
      failure.html { render :edit }
    end
  end

  protected

  def set_current_action
    @current_action = 'email_templates'
  end

  def permitted_params
    params.permit(email_template: %i(subject from cc bcc body template_type name plaintext_body to))
  end
end
