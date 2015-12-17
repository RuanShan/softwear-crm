class AddCustomerKeyToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :customer_key, :string
    Order.all.each do |o|
      o.update_column(:customer_key, rand(36**6).to_s(36).upcase)
    end
  end
end
