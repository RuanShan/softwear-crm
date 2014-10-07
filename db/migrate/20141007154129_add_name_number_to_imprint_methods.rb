class AddNameNumberToImprintMethods < ActiveRecord::Migration
  def up
    imprint_method = ImprintMethod.find_or_create_by(name: 'Name/Number')
    imprint_method.deletable = false


    puts "Unable to save imprintable_method #{ 'Name/Number' }" unless imprint_method.save
    add_column :imprints, :name_format, :string
    add_column :imprints, :number_format, :string
  end

  def down
    imprint_method = ImprintMethod.find_by(name: 'Name/Number')
    imprint_method.destroy if imprint_method

    remove_column :imprints, :name_format
    remove_column :imprints, :number_format
  end
end
