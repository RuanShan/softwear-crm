module BatchUpdate
  extend ActiveSupport::Concern

  NewRecord = Struct.new(:record, :attributes_key) do
    def method_missing(name, *args, &block)
      record.send(name, *args, &block)
    end
  end

  protected

  def batch_update(options = {}, &block)
    resource_name = self.class.controller_name.singularize.to_sym
    params.permit(resource_name).permit!

    resource_attributes = params[resource_name].to_hash

    update_positives(resource_attributes)
    if options[:create_negatives]
      create_from_negatives(resource_attributes, options[:parent])
    end

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

  def create_from_negatives(resource_attributes, parent = nil)
    resource_attributes = inject_parent_id(resource_attributes, parent)

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

  def inject_parent_id(resource_attributes, parent)
    return resource_attributes unless parent

    resource_attributes.dup.tap do |all_attributes|
      all_attributes.values.each do |attributes|
        attributes.merge!(record_id(parent) => parent.id)
      end
    end
  end

  def record_id(record)
    "#{record.class.name.underscore}_id"
  end
end