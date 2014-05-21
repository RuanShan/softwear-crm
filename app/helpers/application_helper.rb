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
end
