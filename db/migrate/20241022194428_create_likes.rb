# frozen_string_literal: true

# Migration to create the likes table for storing user likes on workouts
class CreateLikes < ActiveRecord::Migration[6.1]
  def change
    create_table :likes, if_not_exists: true do |t|
      t.integer :user_id
      t.integer :workout_id
      t.string :name

      t.timestamps
    end
  end
end
