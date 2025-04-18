# frozen_string_literal: true

# The AllsetController handles CRUD operations for workout sets (Allset model).
# It ensures that users can only manage their own sets and provides feedback
# through flash messages and redirects.
class AllsetController < ApplicationController
  include AllsetHelper

  def show
    @exercise = Exercise.find(params[:id])
    if current_user.id == @exercise.user_id
      @page_title = "#{@exercise.name} | Workout"
      @sets = Allset.where(exercise_id: @exercise.id)
      @sets = @sets.order(created_at: :desc)
      @setss = @sets.group_by { |set| set.created_at.to_date }
    else
      redirect_to '/error/permission'
    end
  end

  def edit
    @workout = Allset.find(params[:id])
  end

  def create
    @workout = Allset.new(
      exercise_id: params[:exercise_id],
      user_id: params[:user_id],
      repetitions: params[:repetitions].to_i,
      weight: params[:weight].to_f,
      isFailure: params[:isFailure] == 'on',
      isDropset: params[:isDropset] == 'on',
      isWarmup: params[:isWarmup] == 'on'
    )

    @exercise = Exercise.find(params[:exercise_id])

    respond_to do |format|
      if @workout.save
        # Refresh sets after saving
        @sets = Allset.where(exercise_id: @exercise.id).order(created_at: :desc)
        @setss = @sets.group_by { |set| set.created_at.beginning_of_day }.sort_by { |date, _| date }.reverse

        format.html { redirect_to allset_path(@exercise.id), notice: t('allset.create.success') }
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace('rest-timer', partial: 'allset/sets_list', locals: { sets: @sets, setss: @setss }),
            turbo_stream.replace('dashboard-content', partial: 'dashboard/content')
          ]
        end
      else
        format.html { redirect_to allset_path(@exercise.id), alert: t('allset.create.error') }
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace('rest-timer', partial: 'allset/sets_list', locals: { sets: @sets, setss: @setss }),
            turbo_stream.replace('dashboard-content', partial: 'dashboard/content')
          ], status: :unprocessable_entity
        end
      end
    end
  rescue ActiveRecord::RecordNotFound
    respond_to do |format|
      format.html { redirect_to exercises_path, alert: 'Exercise not found' }
      format.turbo_stream { head :not_found }
    end
  rescue StandardError
    respond_to do |format|
      format.html { redirect_to exercises_path, alert: 'An error occurred' }
      format.turbo_stream { head :internal_server_error }
    end
  end

  def update
    @workout = Allset.find(params[:id])

    if authorized_user?(@workout.user_id)
      if @workout.update(allset_params2)
        redirect_to allset_path(@workout.exercise_id), notice: t('.success')
      else
        redirect_to edit_allset_path(@workout), alert: t('.failure')
      end
    else
      redirect_to permission_error_path
    end
  end

  def destroy
    @workout = Allset.find(params[:id])

    if current_user.id == @workout.user_id
      @exercise = Exercise.find(@workout.exercise_id)

      if @workout.destroy
        @sets = @exercise.sets.order(created_at: :desc)
        @setss = @sets.group_by { |set| set.created_at.beginning_of_day }.sort_by { |date, _| date }.reverse

        respond_to do |format|
          format.html do
            redirect_to allset_path(@exercise.id), notice: 'Set was successfully deleted.'
          end
          format.turbo_stream do
            render turbo_stream: [
              turbo_stream.replace('rest-timer', partial: 'allset/sets_list', locals: { sets: @sets, setss: @setss }),
              turbo_stream.replace('empty-sets-message', partial: 'allset/empty_sets_message', locals: { sets: @sets }),
              turbo_stream.replace('workout-summary', partial: 'workout/summary')
            ]
          end
        end
      else
        Rails.logger.error "Failed to destroy workout: #{@workout.errors.full_messages}"
      end
    else
      Rails.logger.warn "Unauthorized destroy attempt by user #{current_user.id} on workout #{@workout.id}"
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

  def workout_params
    params.permit(:weight, :repetitions, :isFailure, :isDropset, :isWarmup)
  end
end
