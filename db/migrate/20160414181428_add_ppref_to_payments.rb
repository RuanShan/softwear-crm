class AddPprefToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :pp_ref, :string
  end
end
