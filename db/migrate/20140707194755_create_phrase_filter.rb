class CreatePhraseFilter < ActiveRecord::Migration
  def change
    create_table :search_phrase_filters do |t|
      t.string :field
      t.boolean :negate
      t.string :value
    end
  end
end
