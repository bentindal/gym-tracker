class AddBooleanColumnsToAllsets < ActiveRecord::Migration[7.1]
  def change
    add_column :allsets, :isFailure, :boolean, default: false
    add_column :allsets, :isDropset, :boolean, default: false
    add_column :allsets, :isWarmup, :boolean, default: false
  end
end
