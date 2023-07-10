class AddisPublictoUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :isPublic, :boolean, default: true
  end
end
