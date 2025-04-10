# frozen_string_literal: true

# Creates the allsets table
class CreateAllsets < ActiveRecord::Migration[7.1]
  def change
    create_table :allsets do |t|
      t.references :exercise, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.references :belongs_to_workout, foreign_key: { to_table: :workouts }
      t.decimal :weight, precision: 5, scale: 1
      t.integer :repetitions
      t.boolean :warmup, null: false, default: false

      t.timestamps
    end
  end
end
