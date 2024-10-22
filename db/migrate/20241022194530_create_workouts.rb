class CreateWorkouts < ActiveRecord::Migration[6.1]
  def change
    create_table :workouts do |t|
      t.datetime :started_at, precision: nil
      t.datetime :ended_at, precision: nil
      t.integer :user_id
      t.string :title
      t.integer :exercises_used
      t.integer :sets_completed

      t.timestamps
    end
  end
end