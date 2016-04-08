class AddStateToQuotes < ActiveRecord::Migration
  def change
    add_column :quotes, :state, :string
    Quote.unscoped.update_all state: :sent_to_customer
    Quote.unscoped.joins(:order_quotes).update_all state: :won
  end
end
