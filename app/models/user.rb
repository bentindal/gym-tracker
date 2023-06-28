class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

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
         
end
