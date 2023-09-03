class AddHighestStreaktoUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :highest_streak, :integer, default: 0
  end
end
