class AddProductionStateToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :production_state, :string, index: true
    Order.update_all production_state: :pending
  end
end
