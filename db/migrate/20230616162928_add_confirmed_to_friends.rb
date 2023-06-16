class AddConfirmedToFriends < ActiveRecord::Migration[7.0]
  def change
    add_column :friends, :confirmed, :boolean, default: 0
  end
end
