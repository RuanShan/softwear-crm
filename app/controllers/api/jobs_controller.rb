module Api
  class JobsController < ApiController
    protected
    
    def permitted_attributes
      %i(name description)
    end
  end
end