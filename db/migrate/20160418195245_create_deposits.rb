class CreateDeposits < ActiveRecord::Migration
  def up
    create_table :deposits do |t|
      t.decimal :cash_included, precision: 10, scale: 2
      t.decimal :check_included, precision: 10, scale: 2
      t.text :difference_reason
      t.string :deposit_location
      t.string :deposit_id
      t.integer :depositor_id
      t.datetime :deleted_at
      t.timestamps
    end

    add_column :payment_drops, :deposit_id, :integer, index: true
    execute('ALTER TABLE deposits AUTO_INCREMENT = 100')
    PaymentDrop.update_all deposit_id: 1
    PaymentDrop.reindex if Rails.env.production?
  end

  def down
    drop_table :deposits
    remove_column :payment_drops, :deposit_id
  end
end
