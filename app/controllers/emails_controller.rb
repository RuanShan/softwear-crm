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

  private

  def find_email_templates
    @email_templates = EmailTemplate.where(template_type: parent.class.to_s)
  end

  def populate_fields_from_template
    # begin
      @email_template = EmailTemplate.find(params[:email_template_id])
      @email = Email.new if @email.nil?
      @quote = Quote.find(params[:quote_id])
      @email.populate_fields_from_template(@email_template, quote: @quote, user: current_user)
    # rescue Exception => e
    #   flash[:error] = "Sorry, the e-mail template you were looking for does not exist. #{e}"
    # end
  end

end
