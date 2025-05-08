# frozen_string_literal: true

class CreateMetrics < ActiveRecord::Migration[7.0]
  def change
    create_table :metrics do |t|
      t.date :date, null: false
      t.integer :total_users, default: 0
      t.integer :total_workouts, default: 0
      t.integer :total_sets, default: 0
      t.integer :active_users, default: 0
      t.integer :new_users, default: 0

      t.timestamps
    end

    add_index :metrics, :date, unique: true
  end
end
