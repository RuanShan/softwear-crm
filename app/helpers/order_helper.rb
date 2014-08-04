module OrderHelper
  # TODO: refactor to model
  def get_store_id(id)
    id ? Order.find(id).store_id : current_user.store_id
  end

  # TODO: refactor to model
  def get_salesperson_id(id)
    if id
      salesperson_id = Order.find(id).salesperson_id
      return salesperson_id
    end
    current_user.id
  end

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
