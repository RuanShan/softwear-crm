class SeedNonDeletableImprintMethods < ActiveRecord::Migration
  def up
    add_column :imprint_methods, :deletable, :boolean, default: true

    ['Screen Print', 'Digital Print', 'In-House Embroidery',
     'Outsourced Embroidery', 'Transfer Printing', 'Transfer Making',
     'Button Making', 'Name/Number Print'].each do |im|

      imprint_method = ImprintMethod.find_or_create_by(name: im)
      imprint_method.deletable = false

      unless imprint_method.save
        "Unable to save imprintable_method #{ im }"
      end
    end
  end

  def down
    ['Screen Print', 'Digital Print', 'In-House Embroidery',
     'Outsourced Embroidery', 'Transfer Printing', 'Transfer Making',
     'Button Making', 'Name/Number Print'].each do |im|

      imprint_method = ImprintMethod.find_by(name: im)
      imprint_method.destroy if imprint_method
    end

    remove_column :imprint_methods, :deletable
  end
end
