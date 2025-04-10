# frozen_string_literal: true

# The Exercise model represents a specific exercise in a workout. It includes
# associations to the user and related sets, and provides methods for
# calculating workout statistics and visualizing data.
class Exercise < ApplicationRecord
  belongs_to :user
  has_many :sets, class_name: 'Allset', dependent: :destroy

  GROUP_COLOURS = {
    'Chest' => 'primary',
    'Back' => 'danger',
    'Legs' => 'success',
    'Shoulders' => 'warning',
    'Triceps' => 'info',
    'Biceps' => 'info'
  }.freeze

  def group_colour
    GROUP_COLOURS[group] || 'info'
  end

  def workouts_in_range(from, to)
    sets.where(created_at: from..to, isWarmup: false)
  end

  def workouts_on_date(date)
    sets.where(created_at: date.all_day, isWarmup: false)
  end

  def graph_total_volume(from, to)
    calculate_graph_data(from, to) do |sets|
      sets.sum do |set|
        set.weight.to_f * set.repetitions.to_i unless set.isWarmup || set.weight.nil? || set.repetitions.nil?
      end
    end
  end

  def graph_orm(from, to)
    calculate_graph_data(from, to) do |sets|
      sets.map do |set|
        unless set.isWarmup || set.weight.nil? || set.repetitions.nil?
          set.weight.to_f * (1 + (set.repetitions.to_i / 30.0))
        end
      end.compact.max.to_f.round(2)
    end
  end

  private

  def calculate_graph_data(from, to)
    graph_data = {}
    start_point = from.is_a?(String) ? Time.zone.parse(from) : from
    end_point = (to.is_a?(String) ? Time.zone.parse(to) : to).end_of_day

    while start_point < end_point
      sets = workouts_on_date(start_point)
      value = yield(sets)
      graph_data[start_point.strftime('%d/%m')] = value if value.present? && value != 0
      start_point += 1.day
    end

    graph_data
  end
end
