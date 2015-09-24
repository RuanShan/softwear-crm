module ApplicationHelper
  def trackable_link_or_unavailable(activity, attribute=:name)
    return "Which has since been removed" if activity.trackable.nil?
    return link_to activity.trackable.send(attribute), activity.trackable
  end

  def link_to_add_fields(name, f, association)
    new_object = f.object.send(association).new

    id = new_object.object_id
    fields = f.fields_for(association, new_object, child_index: id) do |builder|
      render("#{association.to_s.singularize}_fields", f: builder, object: new_object)
    end
    link_to(name, '#', class: 'btn btn-info js-add-fields',
            data: { id: id, fields: fields.gsub("\n", '') })
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

  def value_time(datetime)
    datetime.strftime('%m/%d/%Y %I:%M %p') unless datetime.blank?
  end

  def display_date(datetime)
    datetime.strftime('%b %d, %Y') unless datetime.blank?
  end

  # takes a string and parses it into a datetime
  def parse_freshdesk_time(fd_time)
    DateTime.strptime(fd_time, '%Y-%m-%dT%H:%M:%S')
  end

  # takes a string date from freshdesk and displays it
  def display_freshdesk_time(fd_time)
    display_time(parse_freshdesk_time(fd_time))
  end

  def imprintable_modal(imprintable)
    link_to imprintable.name, imprintable_path(imprintable),
            class: 'imprintable_modal_link', remote: true
  end

  def xeditable?(object = nil)
    true
  end

  def comment_class(comment)
    comment.role == 'public' ? 'info' : 'danger'
  end

  def sortable_th(text, sort_by)
    arrow = {}
    data  = {}
    data[:sort_by] = sort_by

    if params[:sort] == sort_by.to_s
      if params[:ordering] == 'desc'
        arrow[:class] = 'fa fa-caret-down'
        data[:ordering] = 'asc'
      else
        arrow[:class] = 'fa fa-caret-up'
        data[:ordering] = 'desc'
      end
    end

    content_tag(:th, class: 'sort', data: data) do
      if arrow.empty?
        text
      else
        text + ' ' +content_tag(:i, '', arrow)
      end
        .html_safe
    end
  end

  def shipment_class(shipment)
    shipment.shipped? ? "success" : "danger"
  end

  def max_file_size_message
    if ApplicationController.respond_to?(:max_file_upload_size)
      "Max file size: #{ApplicationController.max_file_upload_size}"
    else
      "You're probably in development and don't care about max file upload size"
    end
  end
end
