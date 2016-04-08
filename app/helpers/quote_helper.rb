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

  def get_quote_state_style(state)
    case state
      when 'pending' then 'label-default'
      when 'sent_to_customer' then 'label-warning'
      when 'won' then 'label-success'
      when 'lost' then 'label-danger'
      else 'label-primary'
    end
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
      return 'Add an option or markup to this quote'
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

  def quantities_and_decoration_prices(jobs)
    jobs.map do |job|
      ref = job.line_items.first
      next if ref.nil?
      { job.id => { quantity: ref.quantity, decoration_price: ref.decoration_price } }
    end
      .compact
      .reduce({}, :merge)
  end

  def quote_requests_for(user)
    quote_requests = user.quote_requests

    if QuoteRequest::QUOTE_REQUEST_STATUSES.include?(session[:quote_request_status])
      quote_requests = quote_requests.where(status: session[:quote_request_status])
    end

    quote_requests
  end

  def filter_quote_requests(salesperson = nil)
    select_tag(
      :quote_request_status,

      options_for_select(
        QuoteRequest::QUOTE_REQUEST_STATUSES.map { |s| [s.humanize, s] },
        session[:quote_request_status]
      ),

      include_blank: true,
      id:            'quote-request-status-select',
      class:         'select2',
      data: {
        page: params[:page],
        salesperson: salesperson.try(:id)
      }
    )
  end

  def quote_request_button(quote_request, next_or_previous)
    next_or_previous = next_or_previous.to_sym
    raise "gotta send :next or :previous" unless [:next, :previous].include?(next_or_previous)

    case quote_request.salesperson_id
    when current_user.id then text = "Your #{next_or_previous.capitalize} Quote Request"
    when nil             then text = "#{next_or_previous.capitalize} Unassigned Quote Request"

    else text = "Their Next Quote Request"
    end

    if next_or_previous == :next
      text = text + " <i class='fa fa-arrow-right'></i>"
    else
      text = "<i class='fa fa-arrow-left'></i> " + text
    end

    link_to text.html_safe, quote_request_path(quote_request.send(next_or_previous)),
      class: "btn btn-primary quote-request-#{next_or_previous}-button"
  end

  # HACK/DEBUG this "fixes" an issue with quotes breaking when imprintables are removed
  # quote_line_items.js uses this span.
  def cleanup_imprintableless_line_item!(source, line_item)
    if @quote
      @quote.issue_warning(
        "Invalid Line Item",
        "A line item without an imprintable was found when rendering "\
        "#{source} and was destroyed.\n\n"\
        "#{JSON.pretty_generate(line_item.serializable_hash)}"
      )
    end

    line_item.destroy
    content_tag(:span, '', class: 'line-item-was-busted')
  end
end
