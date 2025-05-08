# frozen_string_literal: true

module AllsetHelper
  def format_date(date)
    return '' if date.nil?

    if date > Time.now.beginning_of_day - 10.minutes
      ''  # Timer will be shown by the rest-timer controller
    elsif date > Time.now.beginning_of_day - 1.day
      'Today'
    elsif date > Time.now.beginning_of_day - 2.day
      'Yesterday'
    elsif date > Time.now.beginning_of_day - 6.days
      date.strftime('%A')
    else
      date.strftime('%d %B, %Y')
    end
  end

  def set_row_class(set)
    classes = []
    classes << 'text-danger' if set.isFailure
    classes << 'text-info' if set.isDropset
    classes << 'small text-muted' if set.isWarmup
    classes.join(' ')
  end

  def format_set_weight(set)
    if set.weight.zero?
      'BW'
    elsif set.weight.nil?
      '?'
    else
      "#{set.weight}#{@exercise.unit}"
    end
  end

  def format_set_repetitions(set)
    set.repetitions.nil? ? '?' : set.repetitions
  end
end
