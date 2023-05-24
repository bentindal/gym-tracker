class FeedController < ApplicationController
  def view
    list_of_friends_ids = Friend.where(user: current_user.id)
    viewList = [current_user.id]
    list_of_friends_ids.each do |friend|
      viewList.push(friend.follows)
    end
    @feed = []
    viewList.each do |userid|
      @user = User.find(userid)
      @sets = Workout.where(user_id: @user.id)
      @dates = []
      @sets.each do |workout|
          @dates.push(workout.created_at.to_date)
      end
      @dates = @dates.uniq.sort.reverse!
      @exercises = Exercise.where(user_id: @user.id)
      @dates.each do |date|
        @list = []
        @exercises.each do |exercise|
          @list.push([exercise, @sets.where(exercise_id: exercise.id).where(created_at: date.beginning_of_day..date.end_of_day)])
        end
        @feed.push([date, @user, @list])
      end
    end
    # Order feed by date
    @feed = @feed.sort_by { |date, user, list| date }.reverse!
  end
end
