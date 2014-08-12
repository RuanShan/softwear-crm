module BatchUpdate
  extend ActiveSupport::Concern

  NewRecord = Struct.new(:record, :attributes_key)

  protected

  def batch_update(create_negative_ids = false, &block)
    resource_name = self.class.controller_name.singularize.to_sym
    params.permit(resource_name).permit!

    resource_attributes = params[resource_name].to_hash

    update_positives(resource_attributes)
    create_from_negatives(resource_attributes) if create_negative_ids

    respond_to(&block) if block_given?
  end

  private

  def update_positives(resource_attributes)
    updated_resources = resource_attributes
      .keys
      .select { |k| k.to_i >= 0 }
      .map(&resource_class.method(:find))

    instance_variable_set(
      "@#{self.class.controller_name}",
      updated_resources
    )

    updated_resources.each do |resource|
      resource.update_attributes(resource_attributes[resource.id.to_s])
    end
  end

  def create_from_negatives(resource_attributes)
    created_resources = resource_attributes
      .keys
      .select { |k| k.to_i < 0 }
      .map do |k|
          NewRecord.new(resource_class.create(resource_attributes[k]), k)
        end

    instance_variable_set(
      "@new_#{self.class.controller_name}",
      created_resources
    )
    created_resources
  end
end