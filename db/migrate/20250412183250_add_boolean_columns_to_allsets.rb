class AddBooleanColumnsToAllsets < ActiveRecord::Migration[7.1]
  def change
    unless column_exists?(:allsets, :isFailure)
      add_column :allsets, :isFailure, :boolean, default: false
    end
    
    unless column_exists?(:allsets, :isDropset)
      add_column :allsets, :isDropset, :boolean, default: false
    end
    
    unless column_exists?(:allsets, :isWarmup)
      add_column :allsets, :isWarmup, :boolean, default: false
    end
  end
end
