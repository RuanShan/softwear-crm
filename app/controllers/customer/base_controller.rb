module Customer
  class BaseController < InheritedResources::Base

    skip_before_filter :authenticate_user!
    layout 'no_overlay'

    def set_title
      @title = ""
      @title += "#{Rails.env.upcase} - " unless Rails.env.production?
      @title += "Customer Resources - "

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

      @title += "SoftWEAR"
      @title
    end
  end
end
