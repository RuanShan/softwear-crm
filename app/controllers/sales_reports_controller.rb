class SalesReportsController < ApplicationController
  before_filter :initialize_reports
  
  def index
  end

  def create
    redirect_to sales_reports_show_path(start_time: params[:start_time],
                                   end_time: params[:end_time],
                                   report_type: params[:report_type], format: params[:format])
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

  def initialize_reports 
    @reports = Report::SALES_REPORTS
  end

end
