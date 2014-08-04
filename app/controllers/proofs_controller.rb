class ProofsController < InheritedResources::Base
  before_filter :format_time, only: [:create, :update]
  before_filter :approved?, only: [:update]

  # TODO: inherited resources controller?
  belongs_to :order

  respond_to :js

  # TODO: > 2 instance variables, can probably just be local
  def email_customer
    if request.get?
      @proof = Proof.find(params[:id])
      @order = Order.find(params[:order_id])
      @reminder = params[:reminder] == 'true'
    elsif request.post?
      @proof = Proof.find(params[:id])
      @order = Order.find(params[:order_id])
      @reminder = params[:reminder] == 'true'
      body = @reminder ? t('proof_reminder_body_html', firstname: @order.firstname, lastname: @order.lastname) : params[:email_body]
      subject = @reminder ? t('proof_reminder_subject', id: @order.id) : params[:email_subject]

      # TODO: abstract away?
      if @reminder
        ProofMailer.proof_reminder_email(@proof, @order, body, subject).deliver
        flash[:success] = 'Your reminder was successfully sent!'
        @proof.create_activity :reminded_customer, owner: current_user
      else
        ProofMailer.proof_approval_email(@proof, @order, body, subject).deliver
        @proof.status = 'Emailed Customer'
        @proof.save
        flash[:success] = 'Your email was successfully sent!'
        @proof.create_activity :emailed_customer, owner: current_user
      end

      redirect_to edit_order_path(id: @order.id, anchor: 'proofs')
    end
  end

  private

  def approved?
    # TODO: maybe clean up?
    @proof = Proof.find(params[:id])
    if params[:status]=='Approved'
      if @proof.approved_at.nil?
        @proof.approved_at = DateTime.now
        @proof.status = 'Approved'
        # TODO: fire_activity?
        @proof.create_activity :approved_proof, owner: current_user
      end
    elsif params[:status]=='Rejected'
      @proof.status = 'Rejected'
      @proof.approved_at = nil
      @proof.create_activity :rejected_proof, owner: current_user
    else
      @proof.approved_at = nil
    end
  end

  # TODO: format_time!!
  def format_time
    unless params[:status] == 'Approved' or  params[:status] == 'Rejected'
      begin
        time = DateTime.strptime(params[:proof][:approve_by], '%m/%d/%Y %H:%M %p').to_time unless (params[:proof].nil? or params[:proof][:approve_by].nil?)
        offset = (time.utc_offset)/60/60
        adjusted_time = (time - offset.hours).utc
        params[:proof][:approve_by] = adjusted_time
      rescue ArgumentError
        params[:proof][:approve_by]
      end
      end
  end

  def permitted_params
    params.permit(:id,
                  proof: [:id, :order_id, :status, :approve_by, :approved_at,
                          artwork_ids: [],
                          mockups_attributes: [:file, :description, :id, :_destroy]])

  end
end
