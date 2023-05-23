class FeedController < ApplicationController
  def view
    @feed = []
    viewList = [1]
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
  end
end
