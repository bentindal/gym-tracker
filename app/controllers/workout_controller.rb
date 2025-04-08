# frozen_string_literal: true

class WorkoutController < ApplicationController
  def list; end

  def edit
    @workout = Workout.find(params[:id])
    return unless current_user.id != @workout.user_id

    redirect_to '/error/permission'
  end

  def update
    @workout = Workout.find(params[:id])
    if current_user.id == @workout.user_id
      if @workout.update(workout_params)
        redirect_to "/workout/view?id=#{@workout.id}", notice: 'Workout updated successfully'
      else
        Rails.logger.debug @workout.errors.full_messages # Output error messages to the console
        redirect_to edit_workout_path(@workout), notice: 'Error updating workout'
      end
    else
      redirect_to '/error/permission'
    end
  end

  def finish
    @unassigned_sets = Allset.where(user_id: current_user.id, belongs_to_workout: nil).group_by(&:exercise)
    @sets = Allset.where(user_id: current_user.id, belongs_to_workout: nil)

    if @unassigned_sets.length.positive?
      @workout = Workout.new
      @workout.user_id = current_user.id
      @workout.started_at = @sets.first.created_at
      @workout.ended_at = @sets.last.created_at
      # Get the title from unique group names seperated by commas and last being "and"
      @workout.title = @unassigned_sets.keys.map(&:group).uniq.join(', ').reverse.sub(',', '& ').reverse
      @workout.exercises_used = @unassigned_sets.length
      @workout.sets_completed = @sets.length
      @workout.save

      @sets.each do |item|
        item.belongs_to_workout = @workout.id
        item.save
      end

      redirect_to "/workout/view?id=#{@workout.id}", notice: 'Workout successfully ended.'
    else
      redirect_to '/workout/list', alert: 'Cannot end a workout with no sets.'
    end
  end

  private

  def workout_params
    params.require(:workout).permit(:title)
  end
end
