class AddEquipmentToExercises < ActiveRecord::Migration[7.0]
  def change
    add_column :exercises, :equipment, :string
  end
end
