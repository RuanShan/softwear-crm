module UserHelper
  def get_store_id(id)
    if id
      store_id = Order.find(params[:id]).store_id
      return store_id
    end
    store_id = current_user.store_id
  end
end
