# frozen_string_literal: true

# Migration to add workout_id foreign key to allsets table
class AddWorkoutIdToAllsets < ActiveRecord::Migration[6.1]
  def change
    add_reference :allsets, :workout, foreign_key: true
  end
end
