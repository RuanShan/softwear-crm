class EmailsController < InheritedResources::Base
  belongs_to :quote, :order, :polymorphic => true

  def new
    if params[:email_template_id]
      populate_fields_from_template
      new!
    else
      new!
    end
  end

  private

  def populate_fields_from_template
    begin
      @email_template = EmailTemplate.find(params[:email_template_id])
      @email = Email.new if @email.nil?
      @quote = Quote.find(params[:quote_id])
      record_drop = QuoteDrop.new(@quote)
      @email.subject = Liquid::Template.parse(@email_template.subject).render('quote' => record_drop)
      @email.body = Liquid::Template.parse(@email_template.body).render('quote' => record_drop)
    rescue Exception => e
      flash[:error] = "Sorry, the e-mail template you were looking for does not exist. #{e}"
    end
  end

end
