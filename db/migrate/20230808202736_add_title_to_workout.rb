class AddTitleToWorkout < ActiveRecord::Migration[7.0]
  def change
    add_column :workouts, :title, :string
  end
end
