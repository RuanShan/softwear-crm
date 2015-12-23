class AddCalculatedFieldsToOrders < ActiveRecord::Migration
  def up
    add_column :orders, :subtotal, :decimal, precision: 10, scale: 2
    add_column :orders, :taxable_total, :decimal, precision: 10, scale: 2
    add_column :orders, :discount_total, :decimal, precision: 10, scale: 2
    add_column :orders, :payment_total, :decimal, precision: 10, scale: 2

    start = Time.now
    order_count = 0
    Order.find_each do |order|
      begin
        order.recalculate_subtotal
        order.recalculate_taxable_total
        order.recalculate_discount_total
        order.recalculate_payment_total
        order.save(validate: false)
        order_count += 1
      rescue StandardError => e
        puts "-- Order ##{order.id}\n   -> #{e.class}: #{e.message}"
      end
    end
    finish = Time.now

    puts "-- recalculate #{order_count} order fields"
    puts "   -> #{(finish - start).round(4)}s"
  end

  def down
    remove_column :orders, :subtotal, :decimal, precision: 10, scale: 2
    remove_column :orders, :taxable_total, :decimal, precision: 10, scale: 2
    remove_column :orders, :discount_total, :decimal, precision: 10, scale: 2
    remove_column :orders, :payment_total, :decimal, precision: 10, scale: 2
  end
end
