class ErrorReportsController < ApplicationController
  def email_report
    ErrorReportMailer.send_report(params).deliver
    flash[:success] = 'Sent error report. Sorry about that.'
    redirect_to '/'
  end
end
