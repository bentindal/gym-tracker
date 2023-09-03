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
  def sets
    return Allset.where(user_id: self.id)
  end
  def following
    return Friend.where(user: self.id, confirmed: true)
  end

  def followers
    return Friend.where(follows: self.id, confirmed: true)
  end
  def name
    return "#{self.first_name} #{self.last_name}"
  end
  def streak_status
    streak_count = self.streakcount
    two_days_ago = Date.today.day - 2
    one_day_ago = Date.today.day - 1

    # Worked out today
    if has_worked_out_today
      return "active"
    # Didnt workout today but did yesterday
    elsif has_worked_out_today == false && worked_out_on_date(Date.yesterday.day, Date.yesterday.month, Date.yesterday.year)
      return "pending"
    # Didnt workout today or yesterday but did workout the day before
    elsif has_worked_out_today == false && worked_out_on_date(Date.yesterday.yesterday.day, Date.yesterday.yesterday.month, Date.yesterday.yesterday.year)
      return "at_risk"
    # Didnt workout today or yesterday and didnt workout the day before
    else
      return "none"
    end
    
  end
  def has_worked_out_today
    all_workouts = self.sets
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
      return "#{self.first_name} hasn't worked out today, but has a #{self.streakcount} day streak going!"
    elsif self.streak_status == "at_risk"
      return "#{self.first_name} had a day off yesterday, workout today to keep the #{self.streakcount} day streak going or it will be reset!"
    else
      return "#{self.first_name} has a #{self.streakcount} day streak going!"
    end
  end
  def streak_msg_own
    if self.streak_status == "none"
      return "You haven't got a streak going yet."
    elsif self.streak_status == "pending"
      return "You haven't worked out today, but you have a #{self.streakcount} day streak!"
    elsif self.streak_status == "at_risk"
      return "You had a day off yesterday, workout today to keep the #{self.streakcount} day streak going or it will be reset!"
    else
      return "You have a #{self.streakcount} day streak!"
    end
  end
  def midworkout
    if self.sets == []
      return false
    end
    if self.last_set.belongs_to_workout == nil
      return true
    end
    return false
  end
  def last_exercise
    if self.sets == []
      return nil
    else
      return self.sets.last.exercise
    end
  end
  def last_set
    if self.sets == []
      return nil
    else
      return self.sets.last
    end
  end
  def last_seen
    if self.sets == []
      return nil
    else
      last = self.last_set.created_at
      # If greater than a month, print > 1 month
      if last <= Time.now - 1.month
        return "over a month ago"
      # elsif greater than a week, print how many weeks ago
      elsif last <= Time.now - 1.week
        weeks = ((Time.now - last) / 1.week).round
        if weeks == 1
          return "#{weeks} week ago"
        else
          return "#{weeks} weeks ago"
        end

      # elsif greater than a day, print how many days ago
      elsif last <= Time.now - 1.day
        days = ((Time.now - last) / 1.day).round
        if days == 1
          return "#{days} day ago"
        else
          return "#{days} days ago"
        end
      # elsif greater than an hour, print how many hours ago
      elsif last <= Time.now - 1.hour
        hours = ((Time.now - last) / 1.hour).round
        if hours == 1
          return "#{hours} hour ago"
        else
          return "#{hours} hours ago"
        end
      # else, print in minutes
      else
        minutes = ((Time.now - last) / 1.minute).round
        if minutes == 1
          return "#{minutes} minute ago"
        else
          return "#{minutes} minutes ago"
        end
      end
    end
  end
  def workout_count
    return Workout.where(user_id: self.id).count
  end
  def worked_out_on_date(day, month, year)
    all_workouts = self.sets
    # Pad day and month values with a 0 if they are less than 10
    if day.to_i < 10
      day = "0#{day}"
    end
    if month.to_i < 10
      month = "0#{month}"
    end

    all_workouts.each do |workout|
      if workout.created_at.strftime("%d/%m/%Y") == "#{day.to_s}/#{month.to_s}/#{year.to_s}"
        return true
      end
    end
    return false
  end 
  def streak_count
    if self.sets == []
      return 0
    end

    if self.has_worked_out_today
      datePointer = Date.today
    else
      datePointer = Date.yesterday
    end
    
    workedOutToday = false
    streakCount = 0
    gapsUsed = 0
    streakEnded = false
    
    while streakEnded == false
      if worked_out_on_date(datePointer.day, datePointer.month, datePointer.year) == true
        #puts "worked out on #{datePointer.day.to_s}/#{datePointer.month.to_s}/#{datePointer.year.to_s}"
        streakCount += 1
        datePointer = datePointer - 1
        gapsUsed = 0
      elsif gapsUsed == 0
        #puts "did not workout out, 1 gap used #{datePointer.day.to_s}/#{datePointer.month.to_s}/#{datePointer.year.to_s}"
        datePointer = datePointer - 1
        gapsUsed += 1
      else
        #puts "didn't work out on #{datePointer.day.to_s}/#{datePointer.month.to_s}/#{datePointer.year.to_s}"
        streakEnded = true
      end
    end

    return streakCount
  end
  def manually_end_workout
    @unassigned_sets = Allset.where(user_id: self.id, belongs_to_workout: nil).group_by(&:exercise)
    @sets = Allset.where(user_id: self.id, belongs_to_workout: nil)
    
    if @unassigned_sets.length > 0
      @workout = Workout.new
      @workout.user_id = self.id
      @workout.started_at = @sets.first.created_at
      @workout.ended_at = @sets.last.created_at
      @workout.save

      @sets.each do |item|
        item.belongs_to_workout = @workout.id
        item.save
      end

      puts "#{@sets.length} sets assigned to workout #{@workout.id} successfully for user #{self.id}"
    else
      puts "Cannot end a workout with no sets."
    end
  end
end
