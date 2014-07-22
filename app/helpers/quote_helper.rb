module QuoteHelper
  def get_quote_salesperson_id(id)
    if id
      return salesperson_id = Quote.find(id).salesperson_id
    end
    current_user.id
  end

  def get_quote_store_id(id)
    if id
      return store_id = Quote.find(id).store_id
    end
    current_user.store_id
  end
end