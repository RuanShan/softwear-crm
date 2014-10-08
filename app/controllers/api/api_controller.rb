module Api
  class ApiController < ActionController::Base
    include InheritedResources::Actions
    include InheritedResources::BaseHelpers
    extend  InheritedResources::ClassMethods
    extend  InheritedResources::UrlHelpers
    respond_to :json
    self.responder = InheritedResources::Responder

    self.class_attribute :resource_class, :instance_writer => false unless self.respond_to? :resource_class
    self.class_attribute :parents_symbols,  :resources_configuration, :instance_writer => false

    before_filter :permit_id, only: [:show, :update, :destroy]

    def index(&block)
      yield if block_given?

      if records.nil?
        instance_variable_set(
          "@#{self.class.model_name.pluralize.underscore}",

          (records || resource_class)
            .where(params.permit(resource_class.column_names))
        )
      end

      respond_to do |format|
        format.json do
          render json: records, include: includes
        end
      end
    end

    def show
      super do |format|
        format.json(&render_json)
      end
    end

    def create
      super do |format|
        response.headers['Location'] = collection_url(record)
        format.json(&render_json)
      end
    end

    def update
      super do |format|
        format.json(&render_json)
      end
    end

    protected

    def render_json
      proc do
        render json: record, include: includes
      end
    end

    def self.model_name
      name.gsub('Api::', '').gsub('Controller', '').singularize
    end

    # Override this to specify the :include option of rendering json.
    def includes
      nil
    end

    def records
      instance_variable_get("@#{self.class.model_name.underscore.pluralize}")
    end

    def record
      instance_variable_get("@#{self.class.model_name.underscore}")
    end

    private

    def permit_id
      params.permit :id
    end
  end
end