# frozen_string_literal: true

every 5.minutes do # 1.minute 1.day 1.week 1.month 1.year is also supported
  rake 'assign_workouts'
  rake 'update_streaks'
end
