module Api
  class JobsController < Softwear::Lib::ApiController
    protected
    
    def permitted_attributes
      %i(name description)
    end
  end
end
