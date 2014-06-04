module ApplicationHelper

  def model_table_row_id(object)
    return "#{object.class.name.underscore}_#{object.id}"
  end

  def create_or_edit_text(object)
    object.new_record? ? 'Create' : 'Update'
  end

  def unhide_dashboard
    selector = 'button.button-menu-mobile.show-sidebar'
    return if all(selector).empty?
  	find(selector).click
  	wait_for_ajax
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

  def render_error_modal_for(object)
    render partial: 'shared/modal_errors', locals: { object: object }
  end

  # This function creates an open "tag" element in your view, with appropriate classes
  # Pass along the name of the tag you wish to use, whether you want 'active'
  # or 'visible' used for the class, and either an array of controllers or a single controller
  # and this bad boy takes care of the rest, adding the active or visible class
  # to the element if necessary
  def nav_helper(tag, which, controllers)
    if controllers.respond_to? 'each'
      controllers.each do |controller_item|
        if controller.controller_name == controller_item
          if which == 'active'
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

  def with_format(format)
    old_formats = formats
    self.formats = [format]
    yield
    self.formats = old_formats
    nil
  end

end

def test(imprintable)
  imprintable.style.description
end