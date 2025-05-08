# frozen_string_literal: true

class Metric < ApplicationRecord
  validates :date, presence: true, uniqueness: true

  def self.collect_daily_metrics
    today = Time.zone.today
    yesterday = today - 1.day

    # Find or initialize today's metrics
    metric = find_or_initialize_by(date: today)

    # Collect metrics
    metric.total_users = User.count
    metric.total_workouts = Workout.count
    metric.total_sets = Allset.count
    metric.active_users = User.where('last_sign_in_at >= ?', yesterday).count
    metric.new_users = User.where('created_at >= ?', yesterday).count

    metric.save!
  end

  def self.daily_metrics_for_range(start_date, end_date)
    where(date: start_date..end_date).order(date: :asc)
  end

  def self.weekly_metrics_for_range(start_date, end_date)
    metrics = daily_metrics_for_range(start_date, end_date)
    metrics.group_by { |m| m.date.beginning_of_week }
           .transform_values do |week_metrics|
      {
        total_users: week_metrics.last.total_users,
        total_workouts: week_metrics.sum(&:total_workouts),
        total_sets: week_metrics.sum(&:total_sets),
        active_users: week_metrics.sum(&:active_users),
        new_users: week_metrics.sum(&:new_users)
      }
    end
  end

  def self.monthly_metrics_for_range(start_date, end_date)
    metrics = daily_metrics_for_range(start_date, end_date)
    metrics.group_by { |m| m.date.beginning_of_month }
           .transform_values do |month_metrics|
      {
        total_users: month_metrics.last.total_users,
        total_workouts: month_metrics.sum(&:total_workouts),
        total_sets: month_metrics.sum(&:total_sets),
        active_users: month_metrics.sum(&:active_users),
        new_users: month_metrics.sum(&:new_users)
      }
    end
  end
end
