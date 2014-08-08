class SizesController < InheritedResources::Base
  def update
    super do |success, failure|
      success.html { redirect_to sizes_path }
      failure.html { render action: :edit }
    end
  end

  def show
    super do |format|
      format.html { redirect_to edit_size_path params[:id] }
    end
  end

  def update_size_order
    @size_ids = params[:categories]

    ActiveRecord::Base.transaction do
      @size_ids.each_with_index do |temp, n|
        temp = temp.split('_')
        id = temp[1]

        Size.find(id).update(sort_order: n)
      end
    end

    render json: {}
  end

  private

  def permitted_params
    params.permit(size: [:name, :display_value, :sku, :sort_order, :retail])
  end
end
