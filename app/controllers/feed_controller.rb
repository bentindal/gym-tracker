class FeedController < ApplicationController
  def view
    list_of_friends_ids = Friend.where(user: current_user.id, confirmed: true).pluck(:follows)
    # list_of_friends_ids = []
    list_of_friends_ids.push(current_user.id)
    all = []
    @feed = []
    within = 5.hours
    list_of_friends_ids.each do |userid|
      user = User.find(userid)
      # Get all workouts from user
      user.workouts.each do |workout|
        all.push(workout)
      end
      
      all.sort_by! { |workout| workout.created_at }
      
      # Get time 5 hours later than the first workout including date
      if all.first == nil
        next
      end
      time = all.first.created_at + within
      
      # Get all workouts from user that are within the next 5 hours of that workout
      list = []
      remainder = []
      groups = []
      all.each do |workout|
        if workout.created_at <= time && workout.created_at >= time - within
          if workout != nil
            list.push(workout)
          end
          if workout.exercise != "n/a"
            groups.push(workout.exercise.group)
          end
        else
          remainder.push(workout)
        end
      end
      # Combine workouts with the same exercise into one
      list = list.group_by(&:exercise).map do |exercise, workouts|
        [exercise, workouts]
      end
      # If the user has no workouts, skip
      if list[1] == nil
        next
      end
      @feed.push([time - within, list[1].first.user, list, groups.uniq])
      
      while remainder.length > 0
        list = []
        time = remainder.first.created_at + within
        temp = remainder

        remainder = []
        groups = []
        temp.each do |workout|
          if workout.created_at <= time && workout.created_at >= time - within
            if workout != nil
              list.push(workout)
            end
            if workout.exercise != "n/a"
              groups.push(workout.exercise.group)
            end
          else
            remainder.push(workout)
          end
        end
        # Combine workouts with the same exercise into one
        list = list.group_by(&:exercise).map do |exercise, workouts|
          [exercise, workouts]
        end
        if list[1] == nil
          next
        end
        @feed.push([time - within, list[1].first.user, list, groups.uniq])
      end
      
      
    end
    @feed.reverse!
  end
end
