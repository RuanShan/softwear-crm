module OrderHelper
  def get_style_from_state(which, state, style_type='label')
    which = which.to_s
    case which
    when 'invoice_state' then get_style_from_invoice_state(state, style_type)
    when 'notification_state' then get_style_from_notification_state(state, style_type)
    when 'production_state' then get_style_from_production_state(state, style_type)
    when 'payment_state' then get_style_from_status(state, style_type)
    when 'artwork_state' then get_style_from_artwork_state(state, style_type)
    else
      'label-primary'
    end
  end

  def get_style_from_status(status, style_type = 'label')
    if style_type == 'label'
      case status
      when 'Payment Terms Pending' then 'label-danger'
      when 'Awaiting Payment' then 'label-danger'
      when 'Payment Terms Met' then 'label-warning'
      when 'Payment Complete' then 'label-success'
      when 'Canceled' then 'label-danger'
      else nil
      end
    elsif style_type == 'alert'
      case status
      when 'Payment Terms Pending' then 'alert-danger'
      when 'Awaiting Payment' then 'alert-danger'
      when 'Payment Terms Met' then 'alert-warning'
      when 'Payment Complete' then 'alert-success'
      else nil
      end
    end
  end

  def get_style_from_invoice_state(status, style_type = 'label')
    if style_type == 'label'
      case status
      when 'pending' then 'label-warning'
      when 'approved' then 'label-success'
      when 'rejected' then 'label-danger'
      when 'canceled' then 'label-danger'
      else nil
      end
    end
  end

  def get_style_from_artwork_state(status, style_type = 'label')
    if style_type == 'label'
      case status
      when 'pending_artwork_requests' then 'label-danger'
      when 'in_production' then 'label-success'
      when 'artwork_canceled' then 'label-danger'
      else 'label-warning'
      end
    end
  end


  def get_style_from_notification_state(status, style_type = 'label')
    if style_type == 'label'
      case status
      when 'pending' then 'label-danger'
      when 'attempted' then 'label-danger'
      when 'notified' then 'label-warning'
      when 'picked_up' then 'label-success'
      when 'shipped' then 'label-success'
      when 'notification_canceled' then 'label-danger'
      else nil
      end
    end
  end

  def get_style_from_production_state(status, style_type = 'label')
    if style_type == 'label'
      case status
      when 'pending' then 'label-danger'
      when 'in_production' then 'label-warning'
      when 'complete' then 'label-success'
      when 'canceled' then 'label-danger'
      else nil
      end
    end
  end

  def get_train_panel_style(state_type)
    case state_type
      when 'success' then 'panel-success'
      when 'delay' then 'panel-warning'
      when 'failure' then 'panel-danger'
      else 'panel-primary'
    end
  end

  def nav_tab(tag, options = {}, &block)
    options[:class] ||= ''

    if options.delete(:disabled)
      options[:class] += 'no-click'
    else
      options[:data] = { toggle: 'tab' }

      if options.delete(:remote)
        options[:class] += ' remote-nav-tab'
        begin
          options[:data][:url] = "#{collection_url}/#{resource.id}/tab/#{tag}"
        rescue ActiveRecord::RecordNotFoundError => _
          options[:data][:url] = "#{collection_url}/tab/#{tag}"
        end
        options[:data][:tab] = tag
      end
    end

    link_to("##{tag}", options, &block)
  end

  def render_fba_error_handling(fba)
    return render 'orders/error_handling/fba_ok', fba_info: fba if fba.errors.empty?

    fba.errors.reduce(''.html_safe) do |all, error|
      all.send(:original_concat,
        content_tag(:div, class: 'error-result') do
          render(
            "orders/error_handling/fba_#{error.type}", error: error, fba: fba
          )
        end
      )
    end
  end

  def fba_input(tag, *args)
    args.last.merge!(
      'data-original-value' => args.last.delete(:original),
               'onkeypress' => 'return resubmitFbaOnEnter($(this), event);'
    )
    send("#{tag}_tag", *args)
  end

  def fba_resubmit(input_class)
    link_to 'Retry', '#', onclick: "return resubmitButton($(this), '#{input_class}');",
                          class: 'fba-resubmit btn btn-info'
  end

  def render_fba_data(fba)
    hidden_field_tag('job_attributes[]', fba.to_h.to_json)
  end

  def order_cost_options(cost = nil)
    options = ""

    Cost::SELECTABLE_TYPES.each do |cost_type|
      options += content_tag(:option, cost_type, value: cost_type, selected: cost.try(:type) == cost_type)
    end

    if cost && !cost.type.blank? && !Cost::SELECTABLE_TYPES.include?(cost.type)
      options += content_tag(:option, cost.type, value: cost.type, selected: true)
    end

    options += content_tag(:option, "... or enter your own", value: '', disabled: true)

    options.html_safe
  end

  # HACK/DEBUG very similar to the fix in quote_helper.rb. Sometimes line items have
  # imprintable variant IDs that don't belong to imprintable variants
  # orders.js.coffee uses this span.
  def cleanup_invalid_imprintable_variants_for(order)
    return if order.bad_variant_ids.blank?

    order.issue_warning(
      "Bad imprintable variants",
      "This order had line items with imprintable variant ids that don't "+
      "correspond to real imprintable variants. The ids were #{order.bad_variant_ids}."
    )

    order.bad_variant_ids = nil

    content_tag(
      :span, '', class: 'busted-line-item-imprintable-variants'
    )
  end
end
