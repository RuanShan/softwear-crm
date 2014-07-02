module ApplicationHelper


  def link_to_add_fields(name, f, association)
    new_object = f.object.send(association).klass.new
    id = new_object.object_id
    fields = f.fields_for(association, new_object, child_index: id) do |builder|
      render(association.to_s.singularize + "_fields", f: builder)
    end
    link_to(name, '#', class: 'btn btn-info add_fields', data: {id: id, fields: fields.gsub("\n", "")})
  end

  def model_table_row_id(object)
    return "#{object.class.name.underscore}_#{object.id}"
  end

  def create_or_edit_text(object)
    object.new_record? ? 'Create' : 'Update'
  end

  def modal_flash_class(level)
    case level
      when :info then "modal-content-info"
      when :notice then "modal-content-success"
      when :success then "modal-content-success"
      when :error then "modal-content-error"
      when :alert then "modal-content-error"
      when :warning then "modal-content-warning"
    end
  end

  def using(something)
    yield something
  end

  def render_error_modal_for(object)
    render partial: 'shared/modal_errors', locals: { object: object }
  end

  # This function creates an open "tag" element in your view, with appropriate classes
  # Pass along the name of the tag you wish to use, whether you want 'active'
  # or 'visible' used for the class (with a bool), and either an array of controllers or a single controller
  # and this bad boy takes care of the rest, adding the active or visible class
  # to the element if necessary
  def nav_helper(tag, active, controllers)
    if controllers.respond_to? 'each'
      controllers.each do |controller_item|
        if controller.controller_name == controller_item
          if active
            result = tag(tag, {class: 'active'}, true)
          else
            result = tag(tag, {class: 'visible'}, true)
          end
          result.html_safe
          return result
        end
      end
      result = tag(tag, nil, true)
      result.html_safe
      result
    else
      if controller.controller_name == controllers
        result = tag(tag, {class: 'active'}, true)
      else
        result = tag(tag, nil, true)
      end
      result.html_safe
      result
    end
  end

  def human_boolean(bool)
    bool ? 'Yes' : 'No'
  end

  def time_format(datetime)
    datetime.strftime('%m/%d/%Y %H:%M %p') unless datetime.blank?
  end

  def imprintable_modal(imprintable)
    link_to imprintable.name, imprintable_path(imprintable), remote: true, class: 'imprintable_modal_link'
  end
end

def time_format(datetime)
  datetime.strftime('%m/%d/%Y %H:%M %p') unless datetime.blank?
end
