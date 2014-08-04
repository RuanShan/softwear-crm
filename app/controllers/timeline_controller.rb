class TimelineController < ApplicationController
  before_filter :initialize_order

  def show
    respond_to do |format|
      format.html
      # TODO: layout: nil?
      format.js { render layout: nil }
      format.json do
        # TODO: ternary
        activities =
          if params[:after]
            #FIXME: sanitize
            @order.all_activities.where("created_at > ?", params[:after])
          else
            @order.all_activities
          end

        render json: { 
          result: 'success', 
          content: render_string(partial: 'shared/activity_list_items', locals: { activities: activities })
        }
      end
    end
  end

  private

  # TODO: look this over
  def initialize_order
    begin
      @order = Order.find(params[:order_id])
    rescue ActiveRecord::RecordNotFound
      respond_to do |format|
        format.html { redirect_to root_path, flash: { error: 'The order you were looking for could not be found' } }
        # TODO: lol
        format.js { render json: { error: 'not-found' }.to_json, status: 404 }
        format.json do
          render json: { result: 'failure' }
        end
      end
    end
  end
end
