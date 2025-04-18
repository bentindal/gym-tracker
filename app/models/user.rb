# frozen_string_literal: true

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Associations
  has_many :workouts, dependent: :destroy
  has_many :exercises, dependent: :destroy
  has_many :sets, class_name: 'Allset', dependent: :destroy
  has_many :active_friendships, class_name: 'Friend', foreign_key: 'user', dependent: :destroy
  has_many :passive_friendships, class_name: 'Friend', foreign_key: 'follows', dependent: :destroy
  has_many :following, through: :active_friendships, source: :followed
  has_many :followers, through: :passive_friendships, source: :follower

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

  def name
    "#{first_name} #{last_name}"
  end

  def streak_status
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
    workouts.where('started_at >= ?', Time.zone.today.beginning_of_day).exists? ||
      sets.where('created_at >= ?', Time.zone.today.beginning_of_day).exists?
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
      if streakcount.zero?
        "#{first_name} worked out today!"
      else
        "#{first_name} has a #{streakcount} day streak going!"
      end
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
      if streakcount.zero?
        'You worked out today!'
      else
        "You have a #{streakcount} day streak!"
      end
    end
  end

  def streakcount
    streak_count
  end

  def midworkout
    return false if sets.empty?

    sets.where(belongs_to_workout: nil).exists?
  end

  def last_exercise
    return nil if sets.empty?

    sets.last.exercise
  end

  def last_set
    return nil if sets.empty?

    sets.last
  end

  def last_seen
    return nil if sets.empty?

    last = last_set.created_at
    # If greater than a month, print > 1 month
    if last <= 1.month.ago
      'over a month ago'
    # elsif greater than a week, print how many weeks ago
    elsif last <= 1.week.ago
      weeks = ((Time.zone.now - last) / 1.week).round
      return "#{weeks} week ago" if weeks == 1

      "#{weeks} weeks ago"

    # elsif greater than a day, print how many days ago
    elsif last <= 1.day.ago
      days = ((Time.zone.now - last) / 1.day).round
      return "#{days} day ago" if days == 1

      "#{days} days ago"

    # elsif greater than an hour, print how many hours ago
    elsif last <= 1.hour.ago
      hours = ((Time.zone.now - last) / 1.hour).round
      return "#{hours} hour ago" if hours == 1

      "#{hours} hours ago"

    # else, print in minutes
    else
      minutes = ((Time.zone.now - last) / 1.minute).round
      return "#{minutes} minute ago" if minutes == 1

      "#{minutes} minutes ago"

    end
  end

  def workout_count
    workouts.count
  end

  def worked_out_on_date(day, month, year)
    date = Date.new(year, month, day)
    workouts.where('started_at >= ? AND started_at < ?', date.beginning_of_day, date.end_of_day).exists? ||
      sets.where('created_at >= ? AND created_at < ?', date.beginning_of_day, date.end_of_day).exists?
  end

  def streak_count
    return 0 if workouts.empty? && sets.empty?

    date_pointer = if has_worked_out_today
                     Time.zone.today
                   else
                     Date.yesterday
                   end
    streak_count = 0
    gaps_used = 0
    streak_ended = false

    until streak_ended
      if worked_out_on_date(date_pointer.day, date_pointer.month, date_pointer.year)
        streak_count += 1
        date_pointer -= 1
        gaps_used = 0
      elsif gaps_used.zero?
        date_pointer -= 1
        gaps_used += 1
      else
        streak_ended = true
      end
    end

    streak_count
  end

  def manually_end_workout
    unassigned_sets = sets.where(belongs_to_workout: nil)
    return if unassigned_sets.empty?

    workout = Workout.create!(
      user_id: id,
      started_at: unassigned_sets.first.created_at,
      ended_at: unassigned_sets.last.created_at,
      title: "Workout #{Time.zone.now.strftime('%Y-%m-%d %H:%M')}"
    )

    unassigned_sets.update_all(belongs_to_workout: workout.id)
  end
end
