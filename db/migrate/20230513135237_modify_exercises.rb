class ModifyExercises < ActiveRecord::Migration[7.0]
  def change
    remove_column :workouts, :user_id, :integer
  end
end
