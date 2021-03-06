module ApplicationHelper
  def customer_order_path(*args)
    if args.first.is_a?(Order)
      args.first = args.first.customer_key
      super(*args)
    else
      super
    end
  end

  def customer_order_url(*args)
    if args.first.is_a?(Order)
      args.first = args.first.customer_key
      super(*args)
    else
      super
    end
  end

  def check_or_x(bool)
    content_tag(:i, '', class: "fa fa-#{bool ? 'check' : 'times'}")
  end

  def fourteen_days_from_now_at_5
    future_date = 14.days.from_now
    DateTime.new(future_date.year, future_date.month, future_date.day, 17, 0, 0)
  end

  def thirty_days_from_now_at_5
    future_date = 30.days.from_now
    DateTime.new(future_date.year, future_date.month, future_date.day, 17, 0, 0)
  end

  def now_at_5
    now = DateTime.now
    DateTime.new(now.year, now.month, now.day, 17, 0, 0)
  end

  def trackable_link_or_unavailable(activity, attribute=:name)
    return "Which has since been removed" if activity.trackable.nil?
    return link_to activity.trackable.send(attribute), activity.trackable
  end

  def link_to_add_fields(name, f, association, partial = nil)
    new_object = f.object.send(association).new
    id = new_object.object_id
    fields = f.fields_for(association, new_object, child_index: id) do |builder|
      render((partial.nil? ? "#{association.to_s.singularize}_fields" : partial),
             f: builder, object: new_object)
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
    when :info    then 'modal-content-info'
    when :notice  then 'modal-content-success'
    when :success then 'modal-content-success'
    when :error   then 'modal-content-error'
    when :alert   then 'modal-content-error'
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

  def fa(icon)
    content_tag(:i, '', class: "fa fa-#{icon}").html_safe
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
      "The total size of all uploaded files cannot exceed #{ApplicationController.max_file_upload_size}"
    else
      "You're probably in development and don't care about max file upload size"
    end
  end

  def preview_artwork(artwork, size = :medium, options = {})
    img_options = options
    unless artwork.bg_color.blank?
      img_options[:style] = "background-color: #{artwork.bg_color};"
    end

    image_tag artwork.preview.file.url(size), img_options
  end

  def activity_trackable_or_removed(activity, url=nil, options = {})
    if activity.trackable.nil?
      "#{prepend_with_article(activity.trackable_type.underscore.humanize) } that has since been removed"
    else
      text = "#{activity.trackable_type.underscore.humanize} ##{activity.trackable.id}"
      return text unless url
      return link_to(text, url, options) if url
    end
  end

  def activity_recipient_or_removed(activity, url=nil, options = {})
    if activity.recipient.nil?
      "#{activity.recipient_type.underscore.humanize } that has since been removed"
    else
      text = "#{activity.recipient_type.underscore.humanize} ##{activity.recipient.id}"
      return text unless url
      return link_to(text, url, options) if url
    end
  end

  def activity_owner_or_removed(activity, url=nil, options = {})
    if activity.owner.nil?
      "A since deleted user"
    else
      text = activity.owner.full_name
      return text unless url
      return link_to(text, url, options) if url
    end
  end

  def prepend_with_article(string)
    %w(a e i o u).include?(string.downcase.first) ? "an #{self}" : "a #{self}"
  end

  def can_charge_card?
    !Setting.payflow_login.blank? && !Setting.payflow_password.blank?
  end

  def can_do_paypal_express?
    !Setting.paypal_username.blank? &&
    !Setting.paypal_password.blank? &&
    !Setting.paypal_signature.blank?
  end

  def init_address_autocomplete
    javascript_tag "initAddressAutocomplete();"
  end

  def options_with_data_attr(collection, val_method, text_method, selected, data_attrs)
    buf = ''.html_safe

    collection.each do |element|
      data = {}
      data_attrs.each do |key, val_method|
        data[key] = element.send(val_method)
      end

      buf += content_tag(
        :option,
        element.send(text_method),

        value:    element.send(val_method),
        data:     data,
        selected: selected.to_s == element.send(val_method).to_s
      )
    end

    buf
  end

  def search_results_count(options = {})
    return unless @search_result_count
    options[:class] ||= ''
    options[:class] += 'search-results-count'

    content_tag(:h5, "#{@search_result_count || '0'} results", options)
  end

  def search?
    defined? @search_result_count
  end

  def clearfix
    content_tag(:div, "", class: 'clearfix')
  end

  def hash_to_hidden_fields(hash, scope, &block)
    buf = ''.html_safe

    hash.each do |key, value|
      new_scope = "#{scope}[#{key}]"
      if value.is_a?(Hash)
        yield new_scope, value if block_given?
        buf += hash_to_hidden_fields(value, new_scope, &block)
      else
        buf += hidden_field_tag(new_scope, value.to_s)
      end
    end

    buf
  end

  def contact_emails(contact)
    content_tag :ul do
      contact.emails.map do |email|
        email.primary? ? content_tag(:li, "#{email.address} (Primary)") :
          content_tag(:li, "#{email.address}")
      end.join.html_safe
    end.html_safe
  end

  def contact_phone_numbers(contact)
    content_tag :ul do
      contact.phones.map do |phone|
        phone.primary? ? content_tag(:li, "#{phone.full_number} (Primary)") :
          content_tag(:li, "#{phone.full_number}")
      end.join.html_safe
    end.html_safe
  end

  def display_contact_content_or_not(which, contact)
    case which
      when 'existing_contact'
        "display: none" if contact.new_record?
      when 'search_contact_content'
        "display: none"
      when 'new_contact_content'
        "display: none" unless contact.new_record?
      when 'create_new_contact_link'
        "display: none"
      when 'edit_current_contact_link'
        "display: none" if contact.new_record?
      when 'search_existing_contacts_link'
        "display: none" if !contact.new_record?
      when 'change_contact_link'
        "display: none" if contact.new_record?
      when 'cancel_contact_changes_link'
        "display: none"
      else
        ""
    end
  end

end
