module ApplicationHelper
  def link_to_add_fields(name, f, association)
    new_object = f.object.send(association).klass.new
    id = new_object.object_id
    fields = f.fields_for(association, new_object, child_index: id) do |builder|
      render("#{association.to_s.singularize}_fields", f: builder)
    end
    link_to(name, '#', class: 'btn btn-info js-add-fields',
            data: { id: id, fields: fields.gsub("\n", "") })
  end

  def model_table_row_id(object)
    "#{object.class.name.underscore}_#{object.id}"
  end

  def create_or_edit_text(object)
    object.new_record? ? 'Create' : 'Update'
  end

  def modal_flash_class(level)
    case level
    when :info then 'modal-content-info'
    when :notice then 'modal-content-success'
    when :success then 'modal-content-success'
    when :error then 'modal-content-error'
    when :alert then 'modal-content-error'
    when :warning then 'modal-content-warning'
    end
  end

  # TODO: refactor
  def using(something)
    yield something
  end

  def render_error_modal_for(object)
    render 'shared/modal_errors', object: object
  end

  def human_boolean(bool)
    bool ? 'Yes' : 'No'
  end

  def display_time(datetime)
    datetime.strftime('%b %d, %Y, %I:%M %p') unless datetime.blank?
  end

  def imprintable_modal(imprintable)
    link_to imprintable.name, imprintable_path(imprintable),
            class: 'imprintable_modal_link', remote: true
  end

  def xeditable?(object = nil)
    true
  end
end
