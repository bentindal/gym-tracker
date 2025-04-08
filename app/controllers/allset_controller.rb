# frozen_string_literal: true

# The AllsetController handles CRUD operations for workout sets (Allset model).
# It ensures that users can only manage their own sets and provides feedback
# through flash messages and redirects.
class AllsetController < ApplicationController
  def show
    @exercise = Exercise.find(params[:id]) # Use exercise_id instead of params[:id]
    if current_user.id == @exercise.user_id # Check if current user is the owner of the exercise
      @page_title = "#{@exercise.name} | Workout"
      @sets = Allset.where(exercise_id: @exercise.id) # Filter by exercise_id
      @sets = @sets.order(created_at: :desc)
      # Sort sets by uniq date
      @setss = @sets.group_by { |set| set.created_at.to_date }
    else
      redirect_to '/error/permission'
    end
  end

  def edit
    @workout = Allset.find(params[:id])
  end

  def create
    @workout = build_workout_from_params

    if @workout.save
      update_exercise_last_set(@workout.exercise_id, @workout.created_at)
      redirect_to allset_path(@workout.exercise_id), notice: t('.success')
    else
      Rails.logger.error("Allset save failed: #{@workout.errors.full_messages}")
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @workout = Allset.find(params[:id])

    if authorized_user?(@workout.user_id)
      if @workout.update(allset_params2)
        redirect_to allset_path(@workout.exercise_id), notice: t('.success')
      else
        Rails.logger.error("Allset update failed: #{@workout.errors.full_messages}")
        redirect_to edit_allset_path(@workout), alert: t('.failure')
      end
    else
      redirect_to permission_error_path
    end
  end

  def destroy
    @workout = Allset.find(params[:id])
    if current_user.id == @workout.user_id
      @id = @workout.exercise_id
      @workout.destroy
      redirect_to "/allset/#{@id}", notice: t('.success')
    else
      redirect_to '/error/permission'
    end
  end

  private

  def build_workout_from_params
    Allset.new(
      exercise_id: params[:exercise_id],
      user_id: params[:user_id],
      repetitions: params[:repetitions].to_i,
      weight: params[:weight].to_f,
      isFailure: params[:isFailure] == 'on',
      isDropset: params[:isDropset] == 'on',
      isWarmup: params[:isWarmup] == 'on'
    )
  end

  def update_exercise_last_set(exercise_id, last_set_time)
    exercise = Exercise.find(exercise_id)
    exercise.update(last_set: last_set_time)
  end

  def authorized_user?(user_id)
    current_user.id == user_id
  end

  def allset_path(exercise_id)
    "/allset/#{exercise_id}"
  end

  def permission_error_path
    '/error/permission'
  end

  def allset_params
    params.permit(:exercise_id, :user_id, :repetitions, :weight, :isFailure, :isDropset, :isWarmup)
  end

  def allset_params2
    params.require(:allset).permit(:exercise_id, :user_id, :repetitions, :weight, :isFailure, :isDropset, :isWarmup)
  end
end
