# frozen_string_literal: true

desc 'Refresh all streak counts.'
task update_streaks: :environment do
  puts "[#{Time.now}] Updating streaks..."
  User.all.each do |user|
    c = user.streak_count
    if user.streakcount != c
      user.streakcount = c
      puts "#{user.name} set to #{c} day streak."
    end
    if user.highest_streak < c
      user.highest_streak = c
      puts "#{user.name} set to #{c} highest streak."
    end
    user.save
  end
  puts "[#{Time.now}] Streaks updated successfully."
end
