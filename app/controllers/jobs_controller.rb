class JobsController < InheritedResources::Base
  def create
  	
  end

  def update
  	super do |success, failure|
  		success.json { render json: {result: 'success'} }
  		failure.json do
  			render json: {
  				result: 'failure',
  				errors: @job.errors.messages
  			}
  		end
  	end
  end

  def destroy
  	
  end
end
