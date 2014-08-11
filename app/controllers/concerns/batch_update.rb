module BatchUpdate
  extend ActiveSupport::Concern

  protected

  def batch_update(&block)
    resource_name = self.class.controller_name.singularize.to_sym
    params.permit(resource_name).permit!

    resource_attributes = params[resource_name].to_hash
    instance_variable_set(
      "@#{self.class.controller_name}",
      resource_attributes.keys.map(&resource_class.method(:find))
    )

    instance_variable_get("@#{self.class.controller_name}").each do |resource|
      resource.update_attributes(resource_attributes[resource.id.to_s])
    end

    respond_to(&block) if block_given?
  end
end