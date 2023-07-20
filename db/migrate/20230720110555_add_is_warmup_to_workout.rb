class AddIsWarmupToWorkout < ActiveRecord::Migration[7.0]
  def change
    add_column :workouts, :isWarmup, :boolean, default: false
  end
end
