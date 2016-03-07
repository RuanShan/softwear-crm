class AddSizingChartIdToImprintables < ActiveRecord::Migration
  def change
    add_column :imprintables, :sizing_chart_id, :integer
  end
end
