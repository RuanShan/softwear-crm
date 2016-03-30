class LineItemWithCost < LineItem
  has_one :cost, as: :costable
end

class MakeLineItemCostsAFieldToLineItems < ActiveRecord::Migration
  def up
    unless LineItem.column_names.map(&:to_sym).include?(:cost_amount)
      add_column :line_items, :cost_amount, :decimal, scale: 2, precision: 10
    end

    unless Rails.env.test?
      LineItemWithCost.unscoped.joins(:cost).find_each do |li|
        if li.cost.try(:amount)
          li.update_column :cost_amount, li.cost.amount
        end
      end
      puts "  Updated existing line item costs"
    end
  end

  def down
    remove_column :line_items, :cost_amount, :decimal, scale: 2, precision: 10
  end
end
