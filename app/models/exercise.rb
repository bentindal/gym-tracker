# frozen_string_literal: true

# The Exercise model represents a specific exercise in a workout. It includes
# associations to the user and related sets, and provides methods for
# calculating workout statistics and visualizing data.
class Exercise < ApplicationRecord
  belongs_to :user
  has_many :sets, class_name: 'Allset', dependent: :destroy
  validates :name, presence: true

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

  def workouts_on_date(*args)
    date = if args.length == 3
             Time.zone.local(args[2], args[1], args[0])
           else
             args[0]
           end
    sets.where(created_at: date.all_day, isWarmup: false)
  end

  def graph_total_volume(from, to)
    from = 1.month.ago.to_s if from.blank?
    to = Time.current.to_s if to.blank?
    calculate_graph_data(from, to) do |sets|
      sets.sum do |set|
        set.weight.to_f * set.repetitions.to_i unless set.isWarmup || set.weight.nil? || set.repetitions.nil?
      end
    end
  end

  def graph_orm(from, to)
    from = 1.month.ago.to_s if from.blank?
    to = Time.current.to_s if to.blank?
    calculate_graph_data(from, to) do |sets|
      sets.map do |set|
        unless set.isWarmup || set.weight.nil? || set.repetitions.nil?
          (set.weight.to_f * (1 + (set.repetitions.to_i / 30.0))).round
        end
      end.compact.max
    end
  end

  private

  def calculate_graph_data(from, to)
    graph_data = {}
    start_point = Time.zone.parse(from)
    end_point = Time.zone.parse(to).end_of_day

    while start_point < end_point
      sets = workouts_on_date(start_point)
      value = yield(sets)
      graph_data[start_point.strftime('%d/%m')] = value if value.present? && value != 0
      start_point += 1.day
    end

    graph_data
  end
end
