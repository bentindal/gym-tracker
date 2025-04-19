# frozen_string_literal: true

# The WorkoutController manages workout-related actions, including editing,
# updating, and finishing workouts. It ensures proper user permissions and
# provides feedback through flash messages.
class WorkoutController < ApplicationController
  def list; end

  def edit
    @workout = Workout.find(params[:id])
    redirect_to permission_error_path if current_user.id != @workout.user_id
  end

  def update
    @workout = Workout.find(params[:id])
    Rails.logger.info("Updating workout #{@workout.id} with params: #{params.inspect}")

    if authorized_user?(@workout.user_id)
      Rails.logger.info("Authorized user attempting update")
      if @workout.update(workout_params)
        Rails.logger.info("Successfully updated workout #{@workout.id}")
        redirect_to workout_view_path(@workout.id), notice: 'Workout was successfully updated.'
      else
        Rails.logger.error("Workout update failed: #{@workout.errors.full_messages}")
        redirect_to edit_workout_path(@workout), alert: 'Failed to update workout.'
      end
    else
      Rails.logger.warn("Unauthorized update attempt for workout #{@workout.id}")
      redirect_to permission_error_path
    end
  end

  def destroy
    @workout = Workout.find(params[:id])

    if authorized_user?(@workout.user_id)
      if @workout.update(deleted_at: Time.current)
        redirect_to workout_view_path(@workout.id), notice: 'Workout was successfully deleted.'
      else
        redirect_to workout_view_path(@workout.id), alert: 'Failed to delete workout.'
      end
    else
      redirect_to permission_error_path
    end
  end

  def finish
    load_unassigned_sets

    if @unassigned_sets.any?
      create_workout_from_sets
      redirect_to workout_view_path(@workout.id), notice: t('.success')
    else
      redirect_to workout_list_path, alert: t('.failure')
    end
  end

  def view
    @workout = Workout.unscoped.find(params[:id])
    @owner = @workout.user
    @sets = @workout.feed
  end

  private

  def authorized_user?(user_id)
    current_user.id == user_id
  end

  def load_unassigned_sets
    @unassigned_sets = Allset.where(user_id: current_user.id, belongs_to_workout: nil)
                             .where('created_at >= ?', Time.current.beginning_of_day)
                             .group_by(&:exercise)
    @sets = Allset.where(user_id: current_user.id, belongs_to_workout: nil)
                  .where('created_at >= ?', Time.current.beginning_of_day)
  end

  def create_workout_from_sets
    @workout = Workout.new(
      user_id: current_user.id,
      started_at: @sets.first.created_at,
      ended_at: @sets.last.created_at,
      title: generate_workout_title,
      exercises_used: @unassigned_sets.length,
      sets_completed: @sets.length
    )
    @workout.save

    @sets.each { |item| item.update(belongs_to_workout: @workout.id) }
  end

  def generate_workout_title
    @unassigned_sets.keys.map(&:group).uniq.join(', ').reverse.sub(',', '& ').reverse
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

  def workout_params
    params.require(:workout).permit(:title)
  end
end
