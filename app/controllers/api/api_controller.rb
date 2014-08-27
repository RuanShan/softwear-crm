module Api
  class ApiController < ApplicationController
    def index
      records = (records || model).where(params.permit(permitted_attributes))

      respond_to do |format|
        format.json do
          render json: records, include: includes
        end
      end
    end

    def self.model_name
      name.gsub('Api::', '').gsub('Controller', '').singularize
    end

    def self.model
      Kernel.const_get model_name
    end

    def model_name
      self.class.model_name
    end

    def model
      self.clas.model
    end

    protected

    def record
      instance_variable_get(model_name.underscore)
    end

    def record=(new_record)
      instance_variable_set(model_name.underscore, new_record)
    end

    def records
      instance_variable_get(model_name.underscore.pluralize)
    end

    def records=(new_records)
      instance_variable_set(model_name.underscore.pluralize, new_records)
    end

    # Override this to specify which attributes can be filtered on.
    # [:name, :age] would allow a remote ActiveResource to 
    # query where(name: 'Whoever', age: 22)
    def permitted_attributes
      []
    end

    # Override this to specify the :include option of rendering json.
    def includes
      nil
    end
  end
end