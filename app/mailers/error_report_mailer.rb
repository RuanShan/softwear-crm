class ErrorReportMailer < ActionMailer::Base
  def send_report(params)
    @order = Order.find_by(id: params[:order_id])
    @user  = User.find_by(id: params[:user_id])

    if @user.nil?
      from_customer = true

      if @order.nil?
        @user = OpenStruct.new(
          email:     'unknown-user@annarbortees.com',
          full_name: 'Unknown Customer'
        )
      else
        @user = OpenStruct.new(
          email:     @order.email,
          full_name: @order.full_name
        )
      end
    end

    @error_class     = params[:error_class]
    @error_message   = params[:error_message]
    @backtrace       = params[:backtrace]
    @user_message    = params[:user_message]
    @additional_info = params[:additional_info]

    mail(
      from:     from_customer ? 'customer-report@annarbortees.com' : @user.email,
      reply_to: @user.email,
      to:       'devteam@annarbortees.com',
      subject:  "Softwear CRM Error Report From #{@user.full_name}"
    )
  end
end
