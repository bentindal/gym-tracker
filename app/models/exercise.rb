# frozen_string_literal: true

class Exercise < ApplicationRecord
  def user
    User.find(user_id)
  end

  def group_colour
    if group == 'Chest'
      'primary'
    elsif group == 'Back'
      'danger'
    elsif group == 'Legs'
      'success'
    elsif group == 'Shoulders'
      'warning'
    elsif %w[Triceps Biceps].include?(group)
      'info'
    else
      'info'
    end
  end

  def sets
    Allset.where(exercise_id: id)
  end

  def workouts_in_range(from, to)
    Allset.where(exercise_id: id, created_at: from..to, isWarmup: false)
  end

  def workouts_on_date(date)
    Allset.where(exercise_id: id, created_at: date.all_day, isWarmup: false)
  end

  def graph_total_volume(from, to)
    graph_data = {}

    startPoint = DateTime.parse(from)
    endPoint = DateTime.parse(to).end_of_day

    while startPoint < endPoint
      sets = workouts_on_date(startPoint)
      # Do something with sets e.g calculate total volume
      total_volume = 0
      sets.each do |set|
        # Skip any sets that have nil values
        next if set.weight.nil? || set.repetitions.nil? || set.isWarmup == true

        total_volume += set.weight * set.repetitions
      end

      # Only add to graph if there is data for this day
      if total_volume != 0
        graph_data[startPoint.strftime('%d/%m')] = total_volume
        # else
        #    graph_data[startPoint] = 0
      end

      # Iterate to next day and continue
      startPoint += 1.day
    end

    graph_data
  end

  def graph_orm(from, to)
    graph_data = {}

    startPoint = DateTime.parse(from)
    endPoint = DateTime.parse(to).end_of_day

    while startPoint < endPoint

      sets = workouts_on_date(startPoint)
      # Do something with sets e.g calculate total volume
      highest_orm = 0
      sets.each do |set|
        # Skip any sets that have nil values
        next if set.weight.nil? || set.repetitions.nil? || set.isWarmup

        orm = set.weight * (1 + (set.repetitions / 30.0))
        highest_orm = orm if orm > highest_orm
      end
      # Round to 2 decimal places
      highest_orm = highest_orm.round(2)

      # Only add to graph if there is data for this day
      if highest_orm != 0
        graph_data[startPoint.strftime('%d/%m')] = highest_orm
        # else
        #    graph_data[startPoint] = 0
      end

      # Iterate to next day and continue
      startPoint += 1.day
    end

    graph_data
  end
end
