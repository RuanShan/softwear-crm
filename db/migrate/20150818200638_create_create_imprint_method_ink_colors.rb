class CreateCreateImprintMethodInkColors < ActiveRecord::Migration
  def up
    create_table :imprint_method_ink_colors do |t|
      t.integer :imprint_method_id
      t.integer :ink_color_id

      t.timestamps null: false
    end

    imprint_method_ink_color_names = {}

    puts "- Collecting imprint method ink colors"
    ImprintMethod.unscoped.pluck(:id).each do |imprint_method_id|
      InkColor.unscoped.where(imprint_method_id: imprint_method_id).each do |ink_color|
        imprint_method_ink_color_names[imprint_method_id] ||= []
        imprint_method_ink_color_names[imprint_method_id] << ink_color.name
      end
    end

    puts "- Removing old ink colors"
    InkColor.unscoped.destroy_all

    puts "- Re-adding new ink colors using join table"
    imprint_method_ink_color_names.each do |imprint_method_id, ink_color_names|
      ink_color_names.each do |ink_color_name|
        ink_color = InkColor.find_or_create_by(name: ink_color_name)
        ImprintMethodInkColor.create(imprint_method_id: imprint_method_id, ink_color_id: ink_color.id)
      end
    end

    remove_column :ink_colors, :imprint_method_id, :integer
  end

  def down
    drop_table :imprint_method_ink_colors
    add_column :ink_colors, :imprint_method_id, :integer
  end
end
