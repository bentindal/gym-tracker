class CreateWorkouts < ActiveRecord::Migration[7.0]
  def change
    create_table :workouts do |t|
      t.date :started_at
      t.date :ended_at

      t.timestamps
    end
  end
end
