class AddExercisesUsedandSetsCompletedToWorkoutTable < ActiveRecord::Migration[7.0]
  def change
    add_column :workouts, :exercises_used, :integer
    add_column :workouts, :sets_completed, :integer
    # Now for all existing workouts
    Workout.all.each do |workout|
      workout.exercises_used = workout.allsets.group_by(&:exercise).length
      workout.sets_completed = workout.allsets.length
      workout.save
    end
  end
end
