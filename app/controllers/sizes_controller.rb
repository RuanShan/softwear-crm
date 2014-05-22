class SizesController < InheritedResources::Base

  def update
    super do |format|
      format.html { redirect_to sizes_path }
    end
  end

  def show
    super do |format|
      format.html { redirect_to edit_size_path params[:id] }
    end
  end

  def update_size_order
    params.each do |key, value|
      Rails.logger.warn "Param #{key}: #{value}"
    end
    @size_ids = params[:categories]
    n = 0
    ActiveRecord::Base.transaction do
      @size_ids.each do |temp|
        temp = temp.split('_')
        id = temp[1]
        size = Size.find(id)
        size.sequence = n
        n += 1
        size.save
      end
    end
    render :json => {}
  end

  private

  def permitted_params
    params.permit(size: [:name, :display_value, :sku, :sort_order, :sequence])
  end
end
