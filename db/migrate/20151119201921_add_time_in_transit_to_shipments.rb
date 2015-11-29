class AddTimeInTransitToShipments < ActiveRecord::Migration
  def change
    add_column :shipments, :time_in_transit, :decimal, precision: 10, scale: 2
  end
end
