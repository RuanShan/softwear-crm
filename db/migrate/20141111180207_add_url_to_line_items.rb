class AddUrlToLineItems < ActiveRecord::Migration
  def change
    add_column :line_items, :url, :string
  end
end
