# frozen_string_literal: true

class RenameFriendColumns < ActiveRecord::Migration[7.1]
  def change
    rename_column :friends, :user_id, :user if column_exists?(:friends, :user_id)

    return unless column_exists?(:friends, :friend_id)

    rename_column :friends, :friend_id, :follows
  end
end
