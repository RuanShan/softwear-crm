class Crm::ContactsController < InheritedResources::Base

  def index
    @current_action = 'contacts#index'
    @contacts = Crm::Contact.all.page(params[:page])
  end

  private

  def contact_params
    params.required(:crm_contact).permit(
      :first_name, :last_name, :twitter,
      primary_phone_attributes: [
        :number, :extension, :primary
      ],
      primary_email_attributes: [
        :address, :primary
      ],
      emails_attributes: [ :id, :address, :primary, :_destroy ],
      phones_attributes: [ :id, :number, :extension, :primary, :_destroy ]
    )
  end

end
