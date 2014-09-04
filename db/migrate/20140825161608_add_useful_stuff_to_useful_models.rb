class AddUsefulStuffToUsefulModels < ActiveRecord::Migration
  def change
    add_column :imprintables, :common_name, :string
    add_column :imprintable_variants, :weight, :decimal

    add_column :users, :authentication_token, :string
    add_index  :users, :authentication_token
  end
end
