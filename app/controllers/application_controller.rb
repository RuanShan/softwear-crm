class ApplicationController < ActionController::Base
  include PublicActivity::StoreController
  include ApplicationHelper
  include ActsAsWarnable::ApplicationHelper
  include ErrorCatcher

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception unless Rails.env.test?

  before_action :authenticate_user!
  before_action :configure_user_parameters, if: :devise_controller?
  # These allow current_user and the current url to be available to views
  before_action :assign_current_user
  before_action :assign_current_url
  before_action :assign_current_action
  before_action :assign_request_time
  before_action :set_title

  helper_method :salesperson_or_customer

  # Quicker way to render to a string using the `with_format` function down there
  def render_string(*args)
    s = nil
    with_format(:html) { s = render_to_string(*args) }
    s
  end

  protected

  def sales_manager_only
    if current_user.nil? || !current_user.sales_manager?
      redirect_to not_allowed_path
    end
  end

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
    end
  end

  def assign_current_url
    @current_url = request.original_url
  end

  def salesperson_or_customer
    current_user or User.customer
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

  def set_title
    @title = ""
    @title += "#{Rails.env.upcase} - " unless Rails.env.production?
    @title += "CRM - "
    begin
      # resource segment
      if defined?(resource_class) && (resource rescue nil).nil?
        @title += "#{resource_class.to_s.underscore.humanize.pluralize} - "
      elsif defined?(resource_class) && (resource rescue nil).persisted?
        @title += "#{resource_class.to_s.underscore.humanize} ##{resource.id} - "
      elsif defined?(resource_class) && !(resource rescue nil).persisted?
        @title += "#{resource_class.to_s.underscore.humanize} - "
      end

      unless (resource rescue nil).nil?
        @title += "#{resource.name} - " if resource.respond_to?(:name) && !resource.name.blank?
      end

      @title += "#{action_name.humanize} - " unless (action_name rescue nil).nil?
    rescue Exception => e
    end

    @title += "SoftWEAR"
    @title
  end
end
