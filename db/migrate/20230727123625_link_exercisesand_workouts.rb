class LinkExercisesandWorkouts < ActiveRecord::Migration[7.0]
  def change
    # When an exercise is deleted from the database, delete all workouts that contain that exercise
    add_foreign_key :workouts, :exercises, on_delete: :cascade
  end
end
