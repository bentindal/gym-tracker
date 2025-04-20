# frozen_string_literal: true

class AddDeletedAtToWorkouts < ActiveRecord::Migration[6.1]
  def change
    add_column :workouts, :deleted_at, :datetime
    add_index :workouts, :deleted_at
  end
end
