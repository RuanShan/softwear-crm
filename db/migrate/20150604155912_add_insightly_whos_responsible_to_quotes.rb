class AddInsightlyWhosResponsibleToQuotes < ActiveRecord::Migration
  def change
    add_column :quotes, :insightly_whos_responsible_id, :integer
  end
end
