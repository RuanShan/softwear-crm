class AddAssociationsToUserAndOrders < ActiveRecord::Migration
  def change
    add_belongs_to :orders, :user
  end
end
