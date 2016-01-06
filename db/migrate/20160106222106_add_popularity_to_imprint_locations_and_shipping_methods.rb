class AddPopularityToImprintLocationsAndShippingMethods < ActiveRecord::Migration
  def change
    add_column :print_locations, :popularity, :integer, default: 0
    add_column :shipping_methods, :popularity, :integer, default: 0
  end
end
