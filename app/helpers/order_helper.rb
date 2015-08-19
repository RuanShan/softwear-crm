module OrderHelper
  def get_style_from_status(status, style_type = 'label')
    if style_type == 'label'
      case status
      when 'Payment Terms Pending' then 'label-danger'
      when 'Awaiting Payment' then 'label-danger'
      when 'Payment Terms Met' then 'label-warning'
      when 'Payment Complete' then 'label-success'
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

  def render_fba_error_handling(fba)
    return render 'orders/error_handling/fba_ok' if fba.errors.empty?

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
end
