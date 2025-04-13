# frozen_string_literal: true

# The WorkoutController manages workout-related actions, including editing,
# updating, and finishing workouts. It ensures proper user permissions and
# provides feedback through flash messages.
class WorkoutController < ApplicationController
  def list
    @workouts = current_user.workouts.order(started_at: :desc)
  end

  def view
    @workout = Workout.find(params[:id])
    @sets = @workout.sets.group_by(&:exercise)
  end

  def edit
    @workout = Workout.find(params[:id])
    @sets = @workout.sets.group_by(&:exercise)
    redirect_to permission_error_path if current_user.id != @workout.user_id
  end

  def update
    @workout = Workout.find(params[:id])
    if @workout.update(workout_params)
      redirect_to workout_view_path(id: @workout.id), notice: 'Workout updated successfully.'
    else
      render :edit
    end
  end

  def finish
    # Get all unassigned sets
    @unassigned_sets = current_user.sets.where(workout_id: nil).group_by(&:exercise)
    @sets = current_user.sets.where(workout_id: nil)

    # Create a new workout
    @workout = Workout.new(
      user: current_user,
      started_at: @sets.first.created_at,
      ended_at: Time.zone.now,
      title: "Workout on #{Time.zone.now.strftime('%A')}",
      exercises_used: @unassigned_sets.length,
      sets_completed: @sets.length
    )

    if @workout.save
      # Assign all sets to this workout
      @sets.each { |item| item.update(workout: @workout) }
      redirect_to workout_view_path(id: @workout.id), notice: 'Workout finished successfully.'
    else
      redirect_to dashboard_path, alert: 'Error finishing workout.'
    end
  end

  private

  def authorized_user?(user_id)
    current_user.id == user_id
  end

  def workout_params
    params.require(:workout).permit(:title)
  end

  def workout_view_path(workout_id)
    "/workout/view?id=#{workout_id}"
  end

  def workout_list_path
    '/workout/list'
  end

  def permission_error_path
    '/error/permission'
  end
end
