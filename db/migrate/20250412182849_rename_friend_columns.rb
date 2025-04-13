class RenameFriendColumns < ActiveRecord::Migration[7.1]
  def change
    if column_exists?(:friends, :user_id)
      rename_column :friends, :user_id, :user
    end
    
    if column_exists?(:friends, :friend_id)
      rename_column :friends, :friend_id, :follows
    end
  end
end
