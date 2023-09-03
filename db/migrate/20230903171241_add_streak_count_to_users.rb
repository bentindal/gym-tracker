class AddStreakCountToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :streakcount, :integer, default: 0
    allUsers = User.all
    allUsers.each do |user|
      user.streakcount = user.streak_count
      user.save
    end
  end
end
