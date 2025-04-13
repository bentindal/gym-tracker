# frozen_string_literal: true

class AddWorkoutIdToAllsets < ActiveRecord::Migration[7.1]
  def change
    add_column :allsets, :workout_id, :integer
    add_index :allsets, :workout_id
  end
end
