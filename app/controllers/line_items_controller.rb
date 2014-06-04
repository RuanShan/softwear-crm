class LineItemsController < InheritedResources::Base
	def new
		super do |format|
			format.html { render layout: nil, locals: { job: Job.find(params[:job_id]) } }
		end
	end
end
