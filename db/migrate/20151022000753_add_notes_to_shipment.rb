class AddNotesToShipment < ActiveRecord::Migration
  def change
    add_column :shipments, :notes, :text
  end
end
