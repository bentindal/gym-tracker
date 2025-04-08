# frozen_string_literal: true

# Migration to create the allsets table for storing workout sets
class CreateAllsets < ActiveRecord::Migration[6.1]
  def change
    create_table :allsets, if_not_exists: true do |t|
      t.integer :exercise_id
      t.integer :repetitions
      t.decimal :weight
      t.integer :user_id
      t.boolean :isFailure, default: false, null: false
      t.boolean :isDropset, default: false, null: false
      t.boolean :isWarmup, null: false, default: false
      t.integer :belongs_to_workout

      t.timestamps
    end
  end
end
