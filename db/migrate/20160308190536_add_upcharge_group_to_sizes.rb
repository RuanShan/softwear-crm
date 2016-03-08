class AddUpchargeGroupToSizes < ActiveRecord::Migration
  def change
    add_column :sizes, :upcharge_group, :string

    Size.unscoped.where(
      display_value: %w(XXS 2XS XS S M L XL)
    )
      .update_all upcharge_group: 'base_upcharge'

    Size.unscoped.where(display_value: '2XL').update_all upcharge_group: 'xxl_price'
    Size.unscoped.where(display_value: '3XL').update_all upcharge_group: 'xxxl_price'
    Size.unscoped.where(display_value: '4XL').update_all upcharge_group: 'xxxxl_price'
    Size.unscoped.where(display_value: '5XL').update_all upcharge_group: 'xxxxxl_price'
    Size.unscoped.where(display_value: '6XL').update_all upcharge_group: 'xxxxxxl_price'
  end
end
