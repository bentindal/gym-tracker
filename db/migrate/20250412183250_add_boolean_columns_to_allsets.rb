# frozen_string_literal: true

class AddBooleanColumnsToAllsets < ActiveRecord::Migration[7.1]
  def change
    add_column :allsets, :isFailure, :boolean, default: false unless column_exists?(:allsets, :isFailure)

    add_column :allsets, :isDropset, :boolean, default: false unless column_exists?(:allsets, :isDropset)

    return if column_exists?(:allsets, :isWarmup)

    add_column :allsets, :isWarmup, :boolean, default: false
  end
end
