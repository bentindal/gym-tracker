class FeedController < ApplicationController
  def view
    list_of_friends_ids = Friend.where(user: current_user.id, confirmed: true).pluck(:follows)
    # list_of_friends_ids = []
    list_of_friends_ids.push(current_user.id)
    @feed = []
    within = 5.hours
    
    list_of_friends_ids.each do |userid|
      all = []
      user = User.find(userid)
      # Get all workouts from user

      user.workouts.each do |workout|
        all.push(workout)
      end
      
      
      # Get time 5 hours later than the first workout including date
      if all.first == nil
        next
      end
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
        @feed.push([time - within, list[0].first.user, list, groups.uniq])
      end
    end
    @feed = @feed.sort_by { |a| a[0] }.reverse
  end
end
