class Report
  include ActiveModel::Model
  SALES_REPORTS = [
      ['Quote Request Success Report', 'quote_request_success'], 
      ['Payments Report', 'payments'], 
      ['Revenue By Store Report', 'revenue_by_store']
  ]

  attr_accessor :start_time, :end_time, :report_data

  def quote_request_success
    return_hash = {}
    return_hash[:number_of_quote_requests] = QuoteRequest.where(created_at: time_range).count
    return_hash[:number_of_quotes_from_requests] = Quote.joins(:quote_requests).where(quote_requests: { created_at: time_range }).count
    return_hash[:number_of_orders_from_quotes] = Order.joins(:quote_requests).where(quote_requests: { created_at: time_range }).count
    return_hash
  end

  def payments
    time_range = DateTime.strptime(start_time, time_format)..(DateTime.strptime(end_time, time_format) + 1.day)
    return_hash = {}
    return_hash[:payments] = Payment.where(created_at: time_range)
    return_hash[:totals] = Payment.where(created_at: time_range).group(:store_id, :payment_method).sum(:amount)
    return_hash
  end

  def revenue_by_store
    time_range = DateTime.strptime(start_time, time_format)..(DateTime.strptime(end_time, time_format) + 1.day)
    return_hash = {}
    return_hash[:orders] = Order.where(created_at: time_range)
    return_hash
  end

  private

  def time_format 
    time_format = '%Y-%m-%d'
  end

  def time_range
    DateTime.strptime(start_time, time_format)..(DateTime.strptime(end_time, time_format) + 1.day)
  end

end
