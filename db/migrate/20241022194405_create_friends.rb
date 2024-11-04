class CreateFriends < ActiveRecord::Migration[6.1]
  def change
    create_table :friends, if_not_exists: true do |t|
      t.integer :user
      t.integer :follows
      t.boolean :confirmed, default: false

      t.timestamps
    end
  end
end