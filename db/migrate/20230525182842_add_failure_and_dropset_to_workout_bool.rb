class AddFailureAndDropsetToWorkoutBool < ActiveRecord::Migration[7.0]
  def change
    add_column :workouts, :isFailure, :boolean
    add_column :workouts, :isDropset, :boolean
    # Add default value to both to be false
    change_column_default :workouts, :isFailure, false
    change_column_default :workouts, :isDropset, false
  end
end
