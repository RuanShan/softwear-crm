class RefactorQuoteRequestApproxQuantity < ActiveRecord::Migration
  def up
    change_column :quote_requests, :approx_quantity, :string
    change_column :quote_requests, :description, :text
  end

  def down
    change_column :quote_requests, :approx_quantity, :decimal, precision: 5, scale: 2
    change_column :quote_requests, :description, :string
  end

end
