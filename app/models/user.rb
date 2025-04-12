# frozen_string_literal: true

# Represents a user in the system
# Handles user authentication, profile management, and workout tracking
class User < ApplicationRecord
  include TimeFormatting
  include StreakTracking
  include WorkoutTracking

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :first_name, :last_name, :email, presence: true
  validates :email, uniqueness: true

  # First name and last name must be at least 2 characters long & only letters
  validates :first_name, :last_name, length: { minimum: 2 }
  validates :first_name, format: {
    with: /\A[a-zA-Z]+\z/,
    message: :letters_only
  }

  validates :last_name, length: { minimum: 2 }
  validates :last_name, format: {
    with: /\A[a-zA-Z]+\z/,
    message: :letters_only
  }

  # Email must be in correct format
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }

  # Password validation is handled by Devise
  # validates :password, length: { minimum: 6 }
  # validates :password, format: { with: /\A(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*[[:^alnum:]])/x }

  has_many :friends, class_name: 'Friend', foreign_key: 'user', dependent: :destroy, inverse_of: :follower
  has_many :followed_by, class_name: 'Friend', foreign_key: 'follows', dependent: :destroy, inverse_of: :followed

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
    return 'active' if worked_out_today?
    return 'pending' if worked_out_yesterday?
    return 'at_risk' if worked_out_two_days_ago?

    'none'
  end

  def worked_out_today?
    all_workouts = sets
    all_workouts.each do |workout|
      return true if workout.created_at.strftime('%d/%m') == Time.zone.today.strftime('%d/%m')
    end
    false
  end

  def worked_out_yesterday?
    worked_out_on_date(Date.yesterday.day, Date.yesterday.month, Date.yesterday.year)
  end

  def worked_out_two_days_ago?
    worked_out_on_date(Date.yesterday.yesterday.day, Date.yesterday.yesterday.month, Date.yesterday.yesterday.year)
  end

  def streak_msg_other
    I18n.t("user.streak.messages.other.#{streak_status}",
           name: first_name,
           count: streakcount)
  end

  def streak_msg_own
    I18n.t("user.streak.messages.own.#{streak_status}",
           count: streakcount)
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
    return nil if sets.empty?

    time_diff = Time.zone.now - last_set.created_at
    format_time_diff(time_diff.to_i)
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

  alias streakcount streak_count

  def manually_end_workout
    unassigned_sets = Allset.where(user_id: id, belongs_to_workout: nil)
    return if unassigned_sets.empty?

    create_workout_from_sets(unassigned_sets)
  end

  private

  def create_workout_from_sets(sets)
    workout = Workout.create!(
      user_id: id,
      started_at: sets.first.created_at,
      ended_at: sets.last.created_at
    )

    sets.each { |set| set.update!(belongs_to_workout: workout) }

    Rails.logger.debug { "#{sets.length} sets assigned to workout #{workout.id} successfully for user #{id}" }
    workout
  end

  def start_date_for_streak
    if worked_out_today?
      Time.zone.today
    else
      Date.yesterday
    end
  end

  def calculate_streak(start_date)
    streak_count = 0
    gaps_used = 0
    date_pointer = start_date

    until streak_ended?(gaps_used)
      if worked_out_on_date(date_pointer.day, date_pointer.month, date_pointer.year)
        streak_count += 1
        gaps_used = 0
      else
        gaps_used += 1
      end
      date_pointer -= 1
    end

    streak_count
  end

  def streak_ended?(gaps_used)
    gaps_used > 1
  end
end
