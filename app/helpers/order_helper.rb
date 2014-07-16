module OrderHelper
  def get_store_id(id)
    if id
      store_id = Order.find(id).store_id
      return store_id
    end
    store_id = current_user.store_id
  end

  def get_salesperson_id(id)
    if id
      salesperson_id = Order.find(id).salesperson_id
      return salesperson_id
    end
    salesperson_id = current_user.id
  end

  def get_style_from_status(status)
    if status == 'Payment Terms Pending'
      'label-danger'
    elsif status == 'Awaiting Payment'
      'label-danger'
    elsif status == 'Payment Terms Met'
      'label-warning'
    elsif status == 'Payment Complete'
      'label-success'
    end
  end
end
