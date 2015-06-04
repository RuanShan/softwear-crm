module QuoteHelper
  def add_line_items_from_params(f, association, params)
    new_object = f.object.send(association).klass.new
    id = new_object.object_id
    new_object.name = params[:name]
    new_object.description = params[:description]
    new_object.taxable = params[:taxable]
    new_object.quantity = params[:quantity]
    new_object.unit_price = params[:unit_price]
    new_object.url = params[:url]
    f.fields_for(association, new_object, child_index: id) do |builder|
      render(association.to_s.singularize + '_fields', f: builder)
    end
  end

  def line_items_from_last_attempt
    return nil unless session[:last_quote_line_items].try(:values)
    session[:last_quote_line_items]
      .values
      .select { |li| !li['group_name'].nil? }
  end

  def first_step_with_error(quote)
    steps = []
    without_id = lambda do |field|
      field.to_s.gsub(/_id^/, '').to_sym
    end
    quote.errors.each do |field, _message|
      if Quote::STEP_1_FIELDS.include?(field)
        return nil
      elsif Quote::STEP_2_FIELDS.include?(field)
        steps << 2
      elsif Quote::INSIGHTLY_FIELDS.map(&without_id).include?(field)
        steps << 3
      elsif Quote::STEP_4_FIELDS.include?(field)
        steps << 4
      end
    end
    steps.min
  end

  # NOTE this is used for quote_requests/_basic_table.html.erb
  # which must be rendered in Freshdesk, and therefore does not
  # have access to our CSS.
  def qr_t(*args, &block)
    args << { style: 'border: 1px solid black;' }
    content_tag(*args, &block)
  end

  def get_line_item_modal_title(params)
    if params[:imprintable_only]
      return 'Add a imprintable line items to an existing group'
    elsif params[:options_and_markups]
      return 'Add a an option or markup to this quote'
    else
      return 'Add a group of imprintables to this quote'
    end
  end

  def quote_integration_button(quote, type)
    button_message =
      case type.to_sym
      when :insightly then "Generate Opportunity"
      when :freshdesk then "Generate Ticket"
      else raise "Unknown integration type #{type}"
      end

    form_tag(integrate_quote_path(quote), method: :put, remote: true) do
      hidden_field_tag('with', type) +
      button_tag(button_message, class: 'btn btn-success')
    end
  end
end
