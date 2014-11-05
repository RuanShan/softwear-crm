class Report
  include ActiveModel::Model
  SALES_REPORTS = [
      ['Quote Request Success Report', 'quote_request_success']
  ]

  attr_accessor :start_time, :end_time, :report_data

  def quote_request_success
    # fetch # of quote_requests
    time_format = '%Y-%m-%d'
    time_range = DateTime.strptime(start_time, time_format)..DateTime.strptime(end_time, time_format)
    return_hash = {}
    return_hash[:number_of_quote_requests] = QuoteRequest.where(created_at: time_range).count
    return_hash[:number_of_quotes_from_requests] = Quote.joins(:quote_requests).where(quote_requests: { created_at: time_range }).count
    return_hash[:number_of_orders_from_quotes] = Order.joins(:quote_requests).where(quote_requests: { created_at: time_range }).count
    return_hash
  end
end
