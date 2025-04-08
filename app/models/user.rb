# frozen_string_literal: true

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :first_name, :last_name, :email, presence: true
  validates :email, uniqueness: true

  # First name and last name must be at least 2 characters long & only letters
  validates :first_name, :last_name, length: { minimum: 2 }
  validates :first_name, :last_name, format: { with: /\A[a-zA-Z]+\z/,
                                               message: 'only allows letters' }

  validates :last_name, :last_name, length: { minimum: 2 }
  validates :last_name, :last_name, format: { with: /\A[a-zA-Z]+\z/,
                                              message: 'only allows letters' }

  # Email must be in correct format
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }

  # Password must be at least 6 characters long, contain at least 1 uppercase letter, 1 lowercase letter, 1 number and 1 special character
  # validates :password, length: { minimum: 6 }
  # validates :password, format: { with: /\A(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*[[:^alnum:]])/x,
  #  message: "must contain at least 1 uppercase letter, 1 lowercase letter, 1 number and 1 special character" }

  def exercises
    Exercise.where(user_id: id)
  end

  def sets
    Allset.where(user_id: id)
  end

  def following
    Friend.where(user: id, confirmed: true)
  end

  def followers
    Friend.where(follows: id, confirmed: true)
  end

  def name
    "#{first_name} #{last_name}"
  end

  def streak_status
    streakcount
    Date.today.day
    Date.today.day

    # Worked out today
    if has_worked_out_today
      'active'
    # Didnt workout today but did yesterday
    elsif has_worked_out_today == false && worked_out_on_date(Date.yesterday.day, Date.yesterday.month,
                                                              Date.yesterday.year)
      'pending'
    # Didnt workout today or yesterday but did workout the day before
    elsif has_worked_out_today == false && worked_out_on_date(Date.yesterday.yesterday.day,
                                                              Date.yesterday.yesterday.month, Date.yesterday.yesterday.year)
      'at_risk'
    # Didnt workout today or yesterday and didnt workout the day before
    else
      'none'
    end
  end

  def has_worked_out_today
    all_workouts = sets
    all_workouts.each do |workout|
      return true if workout.created_at.strftime('%d/%m') == Date.today.strftime('%d/%m')
    end
    false
  end

  def streak_msg_other
    case streak_status
    when 'none'
      "#{first_name} hasn't worked out yet today!"
    when 'pending'
      "#{first_name} hasn't worked out today, but has a #{streakcount} day streak going!"
    when 'at_risk'
      "#{first_name} had a day off yesterday, workout today to keep the #{streakcount} day streak going or it will be reset!"
    else
      "#{first_name} has a #{streakcount} day streak going!"
    end
  end

  def streak_msg_own
    case streak_status
    when 'none'
      "You haven't got a streak going yet."
    when 'pending'
      "You haven't worked out today, but you have a #{streakcount} day streak!"
    when 'at_risk'
      "You had a day off yesterday, workout today to keep the #{streakcount} day streak going or it will be reset!"
    else
      "You have a #{streakcount} day streak!"
    end
  end

  def midworkout
    return false if sets == []
    return true if last_set.belongs_to_workout.nil?

    false
  end

  def last_exercise
    return nil if sets == []

    sets.last.exercise
  end

  def last_set
    return nil if sets == []

    sets.last
  end

  def last_seen
    return nil if sets == []

    last = last_set.created_at
    # If greater than a month, print > 1 month
    if last <= Time.now - 1.month
      'over a month ago'
    # elsif greater than a week, print how many weeks ago
    elsif last <= Time.now - 1.week
      weeks = ((Time.now - last) / 1.week).round
      return "#{weeks} week ago" if weeks == 1

      "#{weeks} weeks ago"

    # elsif greater than a day, print how many days ago
    elsif last <= Time.now - 1.day
      days = ((Time.now - last) / 1.day).round
      return "#{days} day ago" if days == 1

      "#{days} days ago"

    # elsif greater than an hour, print how many hours ago
    elsif last <= Time.now - 1.hour
      hours = ((Time.now - last) / 1.hour).round
      return "#{hours} hour ago" if hours == 1

      "#{hours} hours ago"

    # else, print in minutes
    else
      minutes = ((Time.now - last) / 1.minute).round
      return "#{minutes} minute ago" if minutes == 1

      "#{minutes} minutes ago"

    end
  end

  def workout_count
    Workout.where(user_id: id).count
  end

  def worked_out_on_date(day, month, year)
    all_workouts = sets
    # Pad day and month values with a 0 if they are less than 10
    day = "0#{day}" if day.to_i < 10
    month = "0#{month}" if month.to_i < 10

    all_workouts.each do |workout|
      return true if workout.created_at.strftime('%d/%m/%Y') == "#{day}/#{month}/#{year}"
    end
    false
  end

  def streak_count
    return 0 if sets == []

    datePointer = if has_worked_out_today
                    Date.today
                  else
                    Date.yesterday
                  end
    streakCount = 0
    gapsUsed = 0
    streakEnded = false

    while streakEnded == false
      if worked_out_on_date(datePointer.day, datePointer.month, datePointer.year) == true
        # puts "worked out on #{datePointer.day.to_s}/#{datePointer.month.to_s}/#{datePointer.year.to_s}"
        streakCount += 1
        datePointer -= 1
        gapsUsed = 0
      elsif gapsUsed.zero?
        # puts "did not workout out, 1 gap used #{datePointer.day.to_s}/#{datePointer.month.to_s}/#{datePointer.year.to_s}"
        datePointer -= 1
        gapsUsed += 1
      else
        # puts "didn't work out on #{datePointer.day.to_s}/#{datePointer.month.to_s}/#{datePointer.year.to_s}"
        streakEnded = true
      end
    end

    streakCount
  end

  def manually_end_workout
    @unassigned_sets = Allset.where(user_id: id, belongs_to_workout: nil).group_by(&:exercise)
    @sets = Allset.where(user_id: id, belongs_to_workout: nil)

    if @unassigned_sets.length.positive?
      @workout = Workout.new
      @workout.user_id = id
      @workout.started_at = @sets.first.created_at
      @workout.ended_at = @sets.last.created_at
      @workout.save

      @sets.each do |item|
        item.belongs_to_workout = @workout.id
        item.save
      end

      puts "#{@sets.length} sets assigned to workout #{@workout.id} successfully for user #{id}"
    else
      puts 'Cannot end a workout with no sets.'
    end
  end
end
