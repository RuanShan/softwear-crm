class CreatePaymentDropPayments < ActiveRecord::Migration
  def up
    create_table :payment_drop_payments do |t|
      t.integer :payment_id, index: true
      t.integer :payment_drop_id, index: true

      t.datetime :deleted_at
      t.timestamps null: false
    end

    # make a drop for each day of payments prior to today
    ending_of_drops = Date.yesterday
    salesperson = User.first
    while Payment.where("created_at < ?", ending_of_drops).count > 0
      Store.all.each do |store|
        payments =  Payment.where("created_at < ? and created_at > ? and store_id = ?", ending_of_drops, ending_of_drops - 1.day, store.id)
        next if payments.count == 0
        cash = payments.where(payment_method: 1).map{|x| x.amount}.reduce(0, :+)
        payment_drop = PaymentDrop.new(
          cash_included: cash,
          salesperson_id: salesperson.id,
          store_id: store.id
        )
        payments.each{|p| payment_drop.payment_drop_payments << PaymentDropPayment.new(payment_id: p.id, payment_drop_id: payment_drop.id)}
        payment_drop.save(validate: false)
        payment_drop.update_columns(created_at: ending_of_drops, updated_at: ending_of_drops)
      end
      ending_of_drops = ending_of_drops - 1.day
    end
  end

  def down
    drop_table :payment_drop_payments
  end
end
