class UserAttributesController < InheritedResources::Base
  defaults resource_class: UserAttributes, collection_name: 'user_attributes_list', instance_name: 'user_attributes'

  def update
    super do |format|
      format.html do
        redirect_to edit_user_attribute_path(@user_attributes)
      end
      format.json do
        render json: @user_attributes
      end
    end
  end

  protected

  def permitted_params
    params.permit(
      user_attributes: [
        :store_id, :freshdesk_email, :freshdesk_password, :insightly_api_key,

        signature_attributes: [:file]
      ]
    )
  end
end
