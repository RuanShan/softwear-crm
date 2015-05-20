class AddDiscontinuedToImprintables < ActiveRecord::Migration
  def change
    add_column :imprintables, :discontinued, :boolean, default: false
  end
end
