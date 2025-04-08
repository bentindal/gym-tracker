# frozen_string_literal: true

# Migration to create the friends table for managing user friendships
class CreateFriends < ActiveRecord::Migration[6.1]
  def change
    create_table :friends, if_not_exists: true do |t|
      t.integer :user_id
      t.integer :friend_id
      t.boolean :confirmed, null: false, default: false

      t.timestamps
    end
  end
end
