class MakeLineItemsImprintableAssociationPolymorphic < ActiveRecord::Migration
  def up
    add_column :line_items, :imprintable_object_id, :integer
    add_column :line_items, :imprintable_object_type, :string

    updated_line_item_counter = 0
    start = Time.now

    LineItem.unscoped.where.not(imprintable_variant_id: nil, line_itemable_id: nil).find_each do |line_item|
      next if line_item[:line_itemable_id].blank?
      next if line_item[:imprintable_variant_id].blank?

      if line_item.line_itemable.try(:jobbable_type) == 'Quote'
        next unless ImprintableVariant.unscoped.where(id: line_item[:imprintable_variant_id]).exists?

        variant = ImprintableVariant.unscoped.find(line_item[:imprintable_variant_id])
        line_item.update_columns(
          imprintable_object_type: 'Imprintable',
          imprintable_object_id: variant[:imprintable_id]
        )
        updated_line_item_counter += 1

      elsif line_item.line_itemable.try(:jobbable_type) == 'Order'
        line_item.update_columns(
          imprintable_object_type: 'ImprintableVariant',
          imprintable_object_id: line_item[:imprintable_variant_id]
        )
        updated_line_item_counter += 1
      end
    end

    puts "-- Updated #{updated_line_item_counter} line item imprintable IDs"
    puts "   -> #{format('%.4f', (Time.now - start).to_f)}s"

    remove_column :line_items, :imprintable_variant_id, :integer
  end

  def down
    remove_column :line_items, :imprintable_object_id, :integer
    remove_column :line_items, :imprintable_object_type, :string
    add_column :line_items, :imprintable_variant_id, :integer
  end
end
