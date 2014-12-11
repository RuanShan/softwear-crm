class EmailTemplatesController < InheritedResources::Base
  before_action :set_current_action
  before_filter :set_associated_models, only: %i(new edit)

  PERMITTED_CLASSES = [Quote]

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

  def fetch_table_attributes
    respond_to do |format|
      if params.has_key?(:table_name)
        @column_names = params[:table_name].safely_constantize(PERMITTED_CLASSES).column_names
      else
        @column_names = []
      end
      format.js
    end
  end

  def preview_body
    respond_to do |format|
      email_template = EmailTemplate.find(params[:email_template_id])
      preview = Liquid::Template.parse(params[:body])
      @body = preview.render(email_template.quote.attributes)
      format.js
    end
  end

protected

  def set_current_action
    @current_action = 'email_templates'
  end

  def set_associated_models
    @associated_models = PERMITTED_CLASSES
  end

  def permitted_params
    params.permit(email_template: %i(subject from cc bcc body quote_id))
  end
end
