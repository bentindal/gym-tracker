class RenameWorkoutTabletoSet < ActiveRecord::Migration[7.0]
  def change
    rename_table :workouts, :sets
  end
end
