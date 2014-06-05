class LineItemsController < InheritedResources::Base
	def new
		super do |format|
			format.html { render layout: nil, locals: { job: Job.find(params[:job_id]) } }
		end
	end

	def create
		super do |success, failure|
			success.json do
        render json: { result: 'success' }
      end
			failure.json do
				modal_html = 'ERROR'
        with_format :html do
          modal_html = render_to_string(partial: 'shared/modal_errors', locals: { object: @line_item })
        end
        render json: {
        	result: 'failure',
        	errors: @line_item.errors.messages,
        	modal: modal_html
        }
			end
		end
	end

private
	def permitted_params
		params.permit(line_item: [
			:id, :name, :description, :quantity, 
			:unit_price, :imprintable_variant_id
		])
	end
end
