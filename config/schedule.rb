# frozen_string_literal: true

# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

set :environment, 'development'
set :output, 'log/whenever.log'

every 5.minutes do # 1.minute 1.day 1.week 1.month 1.year is also supported
  rake 'assign_workouts'
  rake 'update_streaks'
end

# Collect daily metrics at midnight
every 1.day, at: '12:00 am' do
  runner "Metric.collect_daily_metrics"
end

# Clean up old metrics once a week
every :sunday, at: '1:00 am' do
  runner "Metric.cleanup_old_metrics"
end
