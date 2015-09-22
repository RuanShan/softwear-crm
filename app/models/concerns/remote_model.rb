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
            puts "WARNING: *********************************************"
            puts e.message
            puts "******************************************************"
            self.site = "http://invalid-#{slug}.com/api"
          end

        rescue URI::InvalidURIError => e
          puts "WARNING: *********************************************"
          puts e.message
          puts "If you don't plan to use softwear-production integration, you may disregard these."
          puts "******************************************************"
        end
      end

      def self.headers
        if api_settings.nil?
          raise(
            "Please assign api_settings_slug in the model #{self.class.name} " +
            "or add an api setting with slug #{api_settings["slug"]}."
          )
        end

        prefix = api_settings_slug.camelize
        (super or {}).merge(
          "#{prefix}-User-Token" => api_settings["#{api_settings["slug"]}_token"],
          "#{prefix}-User-Email" => api_settings["#{api_settings["slug"]}_email"]
        )
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
