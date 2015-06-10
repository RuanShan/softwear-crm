class ApplicationController < ActionController::Base
  include PublicActivity::StoreController
  include ApplicationHelper
  include ActsAsWarnable::ApplicationHelper

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :authenticate_user!
  before_action :configure_user_parameters, if: :devise_controller?
  # These allow current_user and the current url to be available to views
  before_action :assign_current_user
  before_action :assign_current_url
  before_action :assign_current_action
  before_action :assign_request_time

  rescue_from Exception, StandardError do |error|
    Rails.logger.error "**** #{error.class.name}: #{error.message} ****\n\n"\
      "\t#{error.backtrace.join("\n\t")}"

    @error = error

    respond_to do |format|
      format.html { render 'errors/internal_server_error', status: 500 }
      format.js   { render 'errors/internal_server_error', status: 500 }
      format.json { render json: '{}', status: 500 }
    end
  end

  # Quicker way to render to a string using the previous function
  def render_string(*args)
    s = nil
    with_format(:html) { s = render_to_string(*args) }
    s
  end

  protected

  def sanitize_filename(filename)
    filename.gsub(/[^0-9A-z.\-]/, '_')
  end

  def format_time(input_time)
    begin
      time_zone = Time.zone.now.strftime('%Z')
      utc_time = DateTime.strptime(
        "#{input_time} #{time_zone}", '%m/%d/%Y %l:%M %p %Z'
      )
        .to_time.utc
      return utc_time
    rescue ArgumentError
      return input_time
    end
  end

  def configure_user_parameters
    devise_parameter_sanitizer.for(:sign_up) do |u|
      u.permit :email, :firstname, :lastname
    end
  end

  def assign_current_user
    if current_user
      @current_user = current_user
    else
      @current_user = Struct.new(:full_name).new('Error User')
    end
  end

  def assign_current_url
    @current_url = request.original_url
  end

  def assign_current_action
    @current_action ||= 'dashboard'
  end

  def assign_request_time
    @request_time ||= Time.now
  end

  def fire_activity(record, activity_name, options={})
    options[:key] = record.class.activity_key_for activity_name
    options[:owner] = current_user
    order = TrackingHelpers::Methods.get_order(self, record)
    options[:recipient] = order if order
    record.create_activity options
  end

  # Pulled this off the internet as a way to render templates to a string
  # without using up your one render in a controller.
  # TODO: Nigel, cite resource and merge with render string
  def with_format(format)
    old_formats = formats
    self.formats = [format]
    r = yield
    self.formats = old_formats
    r
  end

  def last_search
    session[:last_search]
  end
end
