class EmailsController < InheritedResources::Base
  belongs_to :quote, :order, :quote_request, :polymorphic => true

  before_filter :assign_info, only: [:new, :create]
  before_filter :find_email_templates, only: [:new, :create]

  respond_to :html, :js

  def new
    @freshdesk = !params[:freshdesk].blank?
    if params[:email_template_id]
      populate_fields_from_template
      new!
    else
      new!
    end
  end

  def create
    super do |success, failure|
      success.html do
        send_email unless @email.freshdesk?

        redirect_to send("#{parent.class.to_s.underscore}_path", parent), success: 'Successfully e-mailed customer their quote details'
      end
      failure.js { render :new }
    end
  end

  def freshdesk
    @email = Email.new(permitted_params[:email])
    @email.freshdesk = true
  end

  private

  def permitted_params
    params.permit(
      email: %i(subject to from cc bcc body plaintext_body freshdesk emailable_type emailable_id)
    )
  end

  def send_email
    QuoteMailer.email_customer(@email).deliver
  end

  def find_email_templates
    @email_templates = EmailTemplate.where(template_type: parent.class.name)
  end

  def populate_fields_from_template
    @email_template = EmailTemplate.find(params[:email_template_id])
    @email = Email.new if @email.nil?

    @email.populate_fields_from_template(@email_template, @object_model => @object, salesperson: current_user)
  end

  def assign_info
    @object_model = parent.class.name.underscore
    @object_type = parent.class.name.underscore.humanize
    @object = @quote || @quote_request || @order
  end

end
