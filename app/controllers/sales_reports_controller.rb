class SalesReportsController < ApplicationController
  def index
    @reports = Report::SALES_REPORTS
  end

  def show
    @report = Report.new(start_time: params[:start_time], end_time: params[:end_time])
    respond_to do |format|
      format.html { render }
      format.csv { render layout: nil}
    end
  end

  private

  def get_data
    if params[:report_type] == 'quote_request_success'
      @total_quote_request_count = 17
    end
  end
end
