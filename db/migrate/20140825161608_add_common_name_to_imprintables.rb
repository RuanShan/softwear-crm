class AddCommonNameToImprintables < ActiveRecord::Migration
  def change
    add_column :imprintables, :common_name, :string
  end
end
