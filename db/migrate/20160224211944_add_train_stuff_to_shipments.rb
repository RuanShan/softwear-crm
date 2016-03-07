class AddTrainStuffToShipments < ActiveRecord::Migration
  def change
    add_column :shipments, :softwear_prod_id, :integer
    add_column :shipments, :softwear_prod_type, :string
  end
end
