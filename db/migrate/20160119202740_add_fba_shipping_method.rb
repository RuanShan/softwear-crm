class AddFbaShippingMethod < ActiveRecord::Migration
  def up
    ShippingMethod.create(
      name: ShippingMethod::FBA,
      tracking_url: 'http://www.ups.com/tracking/tracking.html'
    )
  end
  def down
    ShippingMethod.where(name: ShippingMethod::FBA).destroy_all
  end
end
