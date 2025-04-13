# frozen_string_literal: true

class RemoveBelongsToWorkoutIdFromAllsets < ActiveRecord::Migration[7.1]
  def change
    remove_column :allsets, :belongs_to_workout_id, :integer
  end
end
