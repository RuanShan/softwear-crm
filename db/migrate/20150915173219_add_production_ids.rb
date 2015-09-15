class AddProductionIds < ActiveRecord::Migration
  def change
    add_column :orders,   :softwear_prod_id, :integer
    add_column :jobs,     :softwear_prod_id, :integer
    add_column :imprints, :softwear_prod_id, :integer
  end
end
