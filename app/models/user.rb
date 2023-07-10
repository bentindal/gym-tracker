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
    message: "only allows letters" }
  
  validates :last_name, :last_name, length: { minimum: 2 }
  validates :last_name, :last_name, format: { with: /\A[a-zA-Z]+\z/,
    message: "only allows letters" }
  
  # Email must be in correct format
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }

  # Password must be at least 6 characters long, contain at least 1 uppercase letter, 1 lowercase letter, 1 number and 1 special character
  # validates :password, length: { minimum: 6 }
  #validates :password, format: { with: /\A(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*[[:^alnum:]])/x,
  #  message: "must contain at least 1 uppercase letter, 1 lowercase letter, 1 number and 1 special character" }
  
  def exercises
    return Exercise.where(user_id: self.id)
  end
  def workouts
    return Workout.where(user_id: self.id)
  end
  def friends
    return Friend.where(user_id: self.id, confirmed: true)
  end
  def friend_requests
    return Friend.where(follows: self.id, confirmed: false)
  end
  def streak_count
    all_workouts = self.workouts
    streak_count = 0

    streak_ended = false
    while streak_ended == false
      streak_ended = true
      all_workouts.each do |workout|
        if workout.created_at.strftime("%d/%m") == (Date.yesterday - streak_count).strftime("%d/%m")
          streak_ended = false
        end
      end
      if streak_ended == false
        streak_count += 1
      end
    end
    if has_worked_out_today == true
      streak_count += 1
    end
    return streak_count
  end
  def streak_status
    streak_count = self.streak_count
    if has_worked_out_today == false && streak_count == 0
      return "none"
    elsif streak_count >= 1 && has_worked_out_today == false
      return "pending"
    else
      return "active"
    end
  end
  def has_worked_out_today
    all_workouts = self.workouts
    all_workouts.each do |workout|
      if workout.created_at.strftime("%d/%m") == Date.today.strftime("%d/%m")
        return true
      end
    end
    return false
  end
  def streak_msg_other
    if self.streak_status == "none"
      return "#{self.first_name} hasn't worked out yet today!"
    elsif self.streak_status == "pending"
      return "#{self.first_name} hasn't worked out today, but has a #{self.streak_count} day streak going!"
    else
      return "#{self.first_name} has a #{self.streak_count} day streak going!"
    end
  end
  def streak_msg_own
    if self.streak_status == "none"
      return "You haven't got a streak going yet, start a workout today!"
    elsif self.streak_status == "pending"
      return "You haven't worked out today, but you have a #{self.streak_count} day streak going!"
    else
      return "You have a #{self.streak_count} day streak going, keep it up!"
    end
  end
  
  def feed
    @feed = []
    all = []
    within = 5.hours
    
    user = User.find(self.id)
    # Get all workouts from user

    user.workouts.each do |workout|
      all.push(workout)
    end
    
    
    # Get time 5 hours later than the first workout including date
    time = all.first.created_at + within
    
    # Get all workouts from user that are within the next 5 hours of that workout
    remainder = all

    # Do the same for the remainder of the workouts
    while remainder.length > 0
  
      time = remainder.first.created_at + within
      temp = remainder
      
      list = []
      remainder = []
      groups = []
      temp.each do |workout|
        if workout.created_at <= time && workout.created_at >= time - within
          # List of sets
          list.push(workout)
          groups.push(workout.exercise.group)
        else
          remainder.push(workout)
        end
      end
      # Combine workouts with the same exercise into one
      list = list.group_by(&:exercise).map do |exercise, workouts|
        [exercise, workouts]
      end

      # Time, User, List of workouts, List of groups
      @feed.push([time - within, user, list, groups.uniq])
    end
    @feed = @feed.sort_by { |a| a[0] }.reverse
    return @feed
  end
end
