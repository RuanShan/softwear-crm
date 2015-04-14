class EmailsController < InheritedResources::Base
  belongs_to :quote, :order, :polymorphic => true

  before_filter :find_email_templates, only: [:new, :create]

  respond_to :html, :js

  def new
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
        send_email
        redirect_to send("#{parent.class.to_s.underscore}_path", parent), success: 'Successfully e-mailed customer their quote details'
      end
      failure.html { render :new }
    end
  end

  private

  def permitted_params
    params.permit(email: %i(subject to from cc bcc body plaintext_body))
  end

  def send_email
    QuoteMailer.email_customer(@email).deliver
  end

  def find_email_templates
    @email_templates = EmailTemplate.where(template_type: parent.class.to_s)
  end

  def populate_fields_from_template
    @email_template = EmailTemplate.find(params[:email_template_id])
    @email = Email.new if @email.nil?
    @quote = Quote.find(params[:quote_id])
    @email.populate_fields_from_template(@email_template, quote: @quote, salesperson: current_user)
  end

end
