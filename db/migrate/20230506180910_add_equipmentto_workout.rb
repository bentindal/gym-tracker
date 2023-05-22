class AddEquipmenttoWorkout < ActiveRecord::Migration[7.0]
  def change
    add_column :workouts, :equipment, :string
    remove_column :exercises, :equipment
  end
end
