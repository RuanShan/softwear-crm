class Report
  include ActiveModel::Model
  SALES_REPORTS = [
      ['Quote Request Success Report', 'quote_request_success']
  ]

  attr_accessor :start_time, :end_time, :report_data

  def quote_request_success
    # QuoteRequest.joins(:quotes).joins(:orders).where("order.created_at > #{start_time} and #{end_time}")
    # QuoteRequest.all.limit(3)
    # populates report_data with hash with all the stuff
  #   quote_requests, total quote requests, closed quote requests, whatever,
  end

end