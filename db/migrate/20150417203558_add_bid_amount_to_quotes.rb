class AddBidAmountToQuotes < ActiveRecord::Migration
  def change
    add_column :quotes, :insightly_bid_amount, :decimal, precision: 10, scale: 2
  end
end
