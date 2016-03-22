class SomeSunspotIndexings < ActiveRecord::Migration
  def up
    return if Rails.env.test?
    Sunspot.index Color.all
    puts "Reindexed colors"
    Sunspot.index FbaJobTemplate.all
    puts "Reindexed fba job templates"
    Sunspot.index FbaProduct.all
    puts "Reindexed fba products"
  end

  def down
  end
end
