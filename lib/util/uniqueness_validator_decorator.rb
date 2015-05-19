ActiveRecord::Validations::UniquenessValidator.class_eval do
  # This is copied from rails 4-2-stable branch
  def validate_each(record, attribute, value)
    finder_class = find_finder_class_for(record)
    table = finder_class.arel_table
    value = map_enum_attribute(finder_class, attribute, value)

    begin
      relation = build_relation(finder_class, table, attribute, value)
      relation = relation.and(table[finder_class.primary_key.to_sym].not_eq(record.id)) if record.persisted?
      relation = scope_relation(record, table, relation)
      relation = finder_class.unscoped.where(relation)
      relation = relation.merge(options[:conditions]) if options[:conditions]
      relation = relation.where(record.class.paranoia_column => nil) if record.class.paranoid? #<- ADDED THIS LINE
    rescue RangeError
      relation = finder_class.none
    end

    if relation.exists?
      error_options = options.except(:case_sensitive, :scope, :conditions)
      error_options[:value] = value

      record.errors.add(attribute, :taken, error_options)
    end
  end
end
