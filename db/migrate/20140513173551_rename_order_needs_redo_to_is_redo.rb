class RenameOrderNeedsRedoToIsRedo < ActiveRecord::Migration
  def change
    rename_column :orders, :needs_redo, :is_redo
  end
end
