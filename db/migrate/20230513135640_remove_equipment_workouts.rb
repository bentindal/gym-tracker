class RemoveEquipmentWorkouts < ActiveRecord::Migration[7.0]
  def change
    remove_column :workouts, :equipment
  end
end
