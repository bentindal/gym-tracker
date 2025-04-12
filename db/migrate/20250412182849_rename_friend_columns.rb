class RenameFriendColumns < ActiveRecord::Migration[7.1]
  def change
    rename_column :friends, :user_id, :user
    rename_column :friends, :friend_id, :follows
  end
end
