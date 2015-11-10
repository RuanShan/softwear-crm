class SalesReportsController < ApplicationController
  def index
    @reports = Report::SALES_REPORTS
  end

  def create
    redirect_to sales_reports_show_path(start_time: params[:start_time],
                                   end_time: params[:end_time],
                                   report_type: params[:report_type])
  end

  def show
    @report = Report.new(start_time: params[:start_time], end_time: params[:end_time])
    get_data
    respond_to do |format|
      format.html { render }
      format.csv { render layout: nil }
    end
  end

  private

  def get_data
    @data = @report.send(params[:report_type])
  end
end
