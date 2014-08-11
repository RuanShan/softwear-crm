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
end
