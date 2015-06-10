class ErrorReportMailer < ActionMailer::Base
  def send_report(params)
    @user          = User.find(params[:user_id])
    @error_class   = params[:error_class]
    @error_message = params[:error_message]
    @backtrace     = params[:backtrace]
    @user_message  = params[:user_message]

    mail(
      from: @user.email,
      to: 'devteam@annarbortees.com',
      subject: "Softwear CRM Error Report From #{@user.full_name}"
    )
  end
end
