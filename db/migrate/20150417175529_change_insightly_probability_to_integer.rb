class ChangeInsightlyProbabilityToInteger < ActiveRecord::Migration
  def change
    change_column :quotes, :insightly_probability, :integer
  end
end
