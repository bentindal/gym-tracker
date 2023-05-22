class CreateWorkouts < ActiveRecord::Migration[7.0]
  def change
    create_table :workouts do |t|
      t.integer :exercise_id
      t.integer :repetitions
      t.decimal :weight
      t.string :time_logged

      t.timestamps
    end
  end
end
