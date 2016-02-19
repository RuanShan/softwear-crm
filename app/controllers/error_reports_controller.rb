class ErrorReportsController < ApplicationController
  skip_before_filter :authenticate_user!

  def email_report
    ErrorReportMailer.send_report(params).deliver
    flash[:success] = 'Sent error report. Sorry about that.'

    unless current_user
      begin
        current_user = User.find(params[:user_id]) unless params[:user_id].blank?
      rescue StandardError => e
      end
    end

    if current_user
      redirect_to '/'
    elsif params[:order_id] && (key = Order.where(id: params[:order_id]).pluck(:customer_key).first)
      redirect_to customer_order_path(key)
    else
      render inline: "<%= flash[:success] %>"
    end
  end
end
