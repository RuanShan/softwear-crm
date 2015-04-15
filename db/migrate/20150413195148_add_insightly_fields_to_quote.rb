class AddInsightlyFieldsToQuote < ActiveRecord::Migration
  def change
    add_column :quotes, :insightly_category_id,    :integer
    add_column :quotes, :insightly_probability,    :decimal, precision: 10, scale: 2
    add_column :quotes, :insightly_value,          :decimal, precision: 10, scale: 2
    add_column :quotes, :insightly_pipeline_id,    :integer
    add_column :quotes, :insightly_opportunity_id, :integer
    add_column :quotes, :insightly_bid_tier_id,    :integer
    add_column :quotes, :is_rushed,                :boolean
    add_column :quotes, :qty,                      :integer
    add_column :quotes, :deadline_is_specified,    :boolean
  end
end
