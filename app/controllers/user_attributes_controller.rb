class UserAttributesController < InheritedResources::Base
  defaults resource_class: UserAttributes, collection_name: 'user_attributes_list', instance_name: 'user_attributes'

  def update
    super do |success, failure|
      success.html do
        redirect_to edit_user_attribute_path(@user_attributes)
      end
      failure.html do
        flash[:error] = @user_attributes.errors.full_messages.join(", ")
        render 'edit'
      end

      success.json do
        render json: @user_attributes
      end
      failure.json do
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
