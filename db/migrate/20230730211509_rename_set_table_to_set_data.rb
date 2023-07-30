class RenameSetTableToSetData < ActiveRecord::Migration[7.0]
  def change
    rename_table :sets, :allsets
  end
end
