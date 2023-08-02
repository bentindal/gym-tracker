class WorkoutController < ApplicationController
  def list
  end
  def finish
    @unassigned_sets = Allset.where(user_id: current_user.id, belongs_to_workout: nil).group_by(&:exercise)
    @sets = Allset.where(user_id: current_user.id, belongs_to_workout: nil)
    
    if @unassigned_sets.length > 0
      @workout = Workout.new
      @workout.user_id = current_user.id
      @workout.started_at = @sets.first.created_at
      @workout.ended_at = @sets.last.created_at
      @workout.save

      @sets.each do |item|
        item.belongs_to_workout = @workout.id
        item.save
      end

      redirect_to "/dashboard", notice: "Workout successfully ended."
    else
      redirect_to "/workout/list", alert: "Cannot end a workout with no sets."
    end
  end
end
