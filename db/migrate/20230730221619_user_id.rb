class UserId < ActiveRecord::Migration[7.0]
  def change
    # Add user_id column to workouts table
    add_column :workouts, :user_id, :integer
  end
end
