module Api
  class ApiController < ActionController::Base
    include InheritedResources::Actions
    include InheritedResources::BaseHelpers
    extend  InheritedResources::ClassMethods
    extend  InheritedResources::UrlHelpers

    acts_as_token_authentication_handler_for User
    skip_before_filter :authenticate_user!
    skip_before_filter :verify_authenticity_token

    before_filter :allow_origin

    respond_to :json
    self.responder = InheritedResources::Responder

    self.class_attribute :resource_class, :instance_writer => false unless self.respond_to? :resource_class
    self.class_attribute :parents_symbols,  :resources_configuration, :instance_writer => false

    def index(&block)
      yield if block_given?

      key_values = permitted_attributes.map do |a|
        [a, params[a]] if params.key?(a)
      end
        .compact

      self.records ||= resource_class
      self.records = records.where(Hash[key_values])

      respond_to do |format|
        format.json(&render_json(records))
      end
    end

    def show
      super do |format|
        format.json(&render_json)
      end
    end

    def update
      super do |format|
        format.json(&render_json)
      end
    end

    def create
      create! do |success, failure|
        success.json do
          headers['Location'] = resource_url(record.id)
          render_json.call
        end
        failure.json(&render_json)
      end
    end

    def options
      head(:ok) if request.request_method == 'OPTIONS'
    end

    protected

    def render_json(records = nil)
      proc do
        render json: (records || record),
               methods: [:id] + permitted_attributes,
               include: includes
      end
    end

    def self.model_name
      name.gsub('Api::', '').gsub('Controller', '').singularize
    end

    # Override this to specify the :include option of rendering json.
    def includes
      {}
    end

    def records
      instance_variable_get("@#{self.class.model_name.underscore.pluralize}")
    end

    def records=(r)
      instance_variable_set("@#{self.class.model_name.underscore.pluralize}", r)
    end

    def record
      instance_variable_get("@#{self.class.model_name.underscore}")
    end

    def allow_origin
      headers['Access-Control-Allow-Origin'] = '*'
      headers['Access-Control-Allow-Methods'] = 'GET, POST, PUT, PATCH, DELETE'
      headers['Access-Control-Allow-Headers'] = 'X-Requested-With'
      headers['Access-Control-Allow-Credentials'] = 'true'
    end

    def permitted_attributes
      resource_class.column_names
    end

    private
  end
end
