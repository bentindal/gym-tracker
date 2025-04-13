class CreateWorkoutAnalyses < ActiveRecord::Migration[7.1]
  def change
    create_table :workout_analyses do |t|
      t.references :workout, null: false, foreign_key: true
      t.decimal :total_volume, precision: 10, scale: 2
      t.integer :total_sets
      t.integer :total_reps
      t.decimal :average_weight, precision: 10, scale: 2
      t.text :feedback

      t.timestamps
    end
  end
end 