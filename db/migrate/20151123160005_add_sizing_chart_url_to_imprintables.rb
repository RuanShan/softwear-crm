class AddSizingChartUrlToImprintables < ActiveRecord::Migration
  def change
    add_column :imprintables, :sizing_chart_url, :string
  end
end
