class BatchUpdateError < StandardError
end

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

    update_positives(resource_attributes, options[:assignment])
    if options[:create_negatives]
      create_from_negatives(resource_attributes,
        options[:parent],
        options[:assignment]
      )
    end

    respond_to(&block) if block_given?
  end

  private

  def update_positives(resource_attributes, assignment = nil)
    resource_attributes = sanitize_booleans(resource_attributes)

    updated_resources = resource_attributes
      .keys
      .select { |k| k.to_i >= 0 }
      .map(&resource_class.method(:find))

    assigned = []

    updated_resources.each do |resource|
      attributes = resource_attributes[resource.id.to_s]

      set_attributes(resource, attributes, with: assignment)

      if resource.changed?
        resource.save
        assigned << resource
      end
    end

    instance_variable_set("@#{self.class.controller_name}", assigned)
  end

  def create_from_negatives(resource_attributes, parent = nil, assignment = nil)
    resource_attributes = inject_parent_id(resource_attributes, parent)
    resource_attributes = sanitize_booleans(resource_attributes)

    created_resources = resource_attributes
      .keys
      .select { |k| k.to_i < 0 }
      .map do |k|
          resource = resource_class.new
          attributes = resource_attributes[k]

          set_attributes(resource, attributes, with: assignment)
          resource.save

          NewRecord.new(resource, k)
        end

    instance_variable_set(
      "@new_#{self.class.controller_name}",
      created_resources
    )
    created_resources
  end

  def set_attributes(resource, attributes, options = {})
    assignment = options[:with]
    
    if assignment
      unless assignment.respond_to?(:call)
        raise BatchUpdateError, "Can't #{assignment} is not callable."
      end
      return assignment.call(resource, attributes)
    end

    attributes.each do |key, value|
      resource.send("#{key}=", value) if resource.respond_to?("#{key}=")
    end
  end

  def inject_parent_id(resource_attributes, parent)
    return resource_attributes unless parent

    resource_attributes.dup.tap do |all_attributes|
      all_attributes.values.each do |attributes|
        attributes.merge!(record_id(parent) => parent.id)
      end
    end
  end

  def sanitize_booleans(resource_attributes)
    resource_attributes.dup.tap do |all_attributes|
      all_attributes.values.each do |attributes|
        attributes.each do |key, value|
          if resource_class.columns_hash[key].try(:type) == :boolean
            attributes[key] = value == '1' || value == true
          end
        end
      end
    end
  end

  def comparable(hash)
    hash.to_a.map { |e| [e.first, e.last.to_s] }
  end

  def contained?(x, y)
    (comparable(x) - comparable(y)).empty?
  end

  def record_id(record)
    "#{record.class.name.underscore}_id"
  end
end
