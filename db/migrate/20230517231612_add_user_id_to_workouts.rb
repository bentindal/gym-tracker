class AddUserIdToWorkouts < ActiveRecord::Migration[7.0]
  def change
    add_column :workouts, :user_id, :integer
  end
end
