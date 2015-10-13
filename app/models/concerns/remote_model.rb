require 'active_resource'

module RemoteModel
  extend ActiveSupport::Concern

  included do
    class << self
      def api_settings_slug=(slug)
        @api_settings_slug = slug

        define_singleton_method :api_settings do
          @api_settings ||= Setting.where("name like ?", "#{slug}%").each_with_object({}) {|r, h| h[r.name] = r.val  }
        end

        begin
          begin
            self.site = api_settings["#{slug}_endpoint"] || "http://invalid-#{slug.to_s.dasherize}.com/api"

          rescue ActiveRecord::StatementInvalid => e
            Rails.logger.error "WARNING: *********************************************"
            Rails.logger.error e.message
            Rails.logger.error "******************************************************"
            self.site = "http://invalid-#{slug}.com/api"
          end

        rescue URI::InvalidURIError => e
          Rails.logger.error "WARNING: *********************************************"
          Rails.logger.error e.message
          Rails.logger.error "If you don't plan to use softwear-production integration, you may disregard these."
          Rails.logger.error "******************************************************"
        end
      end

      unless Rails.env.test?
        def headers
          if api_settings.nil?
            raise(
              "Please assign api_settings_slug in the model #{self.class.name} " +
              "or add an api setting with slug #{@api_settings_slug}."
            )
          end

          (super or {}).merge(
            "X-User-Token" => api_settings["#{@api_settings_slug}_token"],
            "X-User-Email" => api_settings["#{@api_settings_slug}_email"]
          )
        end
      end

      def post_raw(data)
        inst = self.new

        connection.post(collection_path, { model_name.element => data }.to_json, headers).tap do |response|
          inst.instance_eval do
            self.id = id_from_response(response)
            load_attributes_from_response(response)
          end
        end

        inst
      end
    end
  end
end
