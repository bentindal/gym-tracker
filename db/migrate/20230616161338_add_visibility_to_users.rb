class AddVisibilityToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :isPublic, :boolean, default: 1
  end
end
