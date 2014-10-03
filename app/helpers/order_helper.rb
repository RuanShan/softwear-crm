module OrderHelper
  def get_style_from_status(status)
    case status
    when 'Payment Terms Pending' then 'label-danger'
    when 'Awaiting Payment' then 'label-danger'
    when 'Payment Terms Met' then 'label-warning'
    when 'Payment Complete' then 'label-success'
    else nil
    end
  end

  def render_fba_error_handling(fba)
    return render 'error_handling/fba_ok' if fba.errors.empty?

    fba.errors.reduce('') do |all, error|
      all + render("error_handling/fba_#{error.type}", error: error)
    end
  end
end
