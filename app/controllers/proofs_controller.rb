class ProofsController < InheritedResources::Base
  before_filter :approved?, only: [:update]
  before_filter :format_approve_by, only: [:create, :update]

  belongs_to :order

  respond_to :js

  def email_customer
    reminder = params[:reminder] == 'true'
    order = Order.find(params[:order_id])
    proof = Proof.find(params[:id])
    if request.get?
      @variable_hash = {
        order: order, proof: proof, reminder: reminder
      }
    elsif request.post?
      email_hash = {
        body: email_body(order, reminder),
        subject: email_subject(order, reminder),
        order: Order.find(params[:order_id]),
        proof: Proof.find(params[:id]),
        reminder: reminder
      }
      email_type(email_hash)
      redirect_to edit_order_path(id: params[:order_id], anchor: 'proofs')
    end
  end

  private

  def approved?
    @proof = Proof.find(params[:id])
    case params[:status]
    when 'Approved'
      @proof.approved_at = DateTime.now
      @proof.status = 'Approved'
      @proof.create_activity :approved_proof, owner: current_user
    when 'Rejected'
      @proof.approved_at = nil
      @proof.status = 'Rejected'
      @proof.create_activity :rejected_proof, owner: current_user
    else
      @proof.approved_at = nil
    end
  end

  def email_body(order, reminder)
    if reminder
      t('proof_reminder_body_html', firstname: order.firstname, lastname: order.lastname)
    else
      params[:email_body]
    end
  end

  def email_subject(order, reminder)
    if reminder
      t('proof_reminder_subject', id: order.id)
    else
      params[:email_subject]
    end
  end

  def email_type(email_hash)
    if email_hash[:reminder]
      ProofMailer.proof_reminder_email(email_hash).deliver
      flash[:success] = 'Your reminder was successfully sent!'
      email_hash[:proof].create_activity :reminded_customer, owner: current_user
    else
      ProofMailer.proof_approval_email(email_hash).deliver
      email_hash[:proof].status = 'Emailed Customer'
      email_hash[:proof].save
      flash[:success] = 'Your email was successfully sent!'
      email_hash[:proof].create_activity :emailed_customer, owner: current_user
    end
  end

  def format_approve_by
    if params[:status] != 'Approved' ||  params[:status] != 'Rejected'
      unless params[:proof].nil? or params[:proof][:approve_by].nil?
        approve_by = params[:proof][:approve_by]
        params[:proof][:approve_by] = format_time(approve_by)
      end
    end
  end

  def permitted_params
    params.permit(:id,
                  proof: [
                    :id, :order_id, :status, :approve_by, :approved_at, artwork_ids: [],
                    mockups_attributes: [:file, :description, :id, :_destroy]
                  ])

  end
end
