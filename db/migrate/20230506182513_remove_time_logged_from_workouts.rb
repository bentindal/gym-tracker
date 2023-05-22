class RemoveTimeLoggedFromWorkouts < ActiveRecord::Migration[7.0]
  def change
    remove_column :workouts, :time_logged, :string
  end
end
