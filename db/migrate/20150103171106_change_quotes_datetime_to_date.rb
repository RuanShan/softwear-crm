class ChangeQuotesDatetimeToDate < ActiveRecord::Migration
  def change
    def up
      change_column :quotes, :valid_until_date, :date
      change_column :quotes, :estimated_delivery_date, :date
    end

    def down
      change_column :quotes, :valid_until_date, :datetime
      change_column :quotes, :estimated_delivery_date, :datetime
    end
  end
end
