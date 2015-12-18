class ErrorReportsController < ApplicationController
  skip_before_filter :authenticate_user!

  def email_report
    ErrorReportMailer.send_report(params).deliver
    flash[:success] = 'Sent error report. Sorry about that.'

    if current_user
      redirect_to '/'
    elsif params[:order_id] && (key = Order.where(id: params[:order_id]).pluck(:customer_key).first)
      redirect_to customer_order_path(key)
    else
      render inline: "<%= params[:success] %>"
    end
  end
end
