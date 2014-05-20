module ApplicationHelper

  def model_table_row_id(object)
    return "#{object.class.name.underscore}_#{object.id}"
  end

  def create_or_edit_text(object)
    object.new_record? ? 'Create' : 'Update'
  end

  def unhide_dashboard
  	find('button.button-menu-mobile.show-sidebar').click
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

  def nav_active_or_visible_class(tag, which, controller)
    if controller == 'imprintables' or controller == 'sizes' or
        controller == 'brands' or controller == 'colors' or
        controller == 'styles'
      if which == 'active'
        result = tag(tag, {class: 'active'}, true)
      else
        result = tag(tag, {class: 'visible'}, true)
      end
    else
      result = tag(tag, nil, true)
    end
    result.html_safe
  end

  def nav_active_li(controller, title)
    if controller == title
      result = tag :li, class: 'active'
    else
      result = tag :li
    end
    result.html_safe
  end
end
