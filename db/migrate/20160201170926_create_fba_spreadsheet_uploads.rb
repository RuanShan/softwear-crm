class CreateFbaSpreadsheetUploads < ActiveRecord::Migration
  def change
    create_table :fba_spreadsheet_uploads do |t|
      t.boolean :done
      t.text :spreadsheet
      t.text :processing_errors
      t.string :filename

      t.timestamps null: false
    end
  end
end
