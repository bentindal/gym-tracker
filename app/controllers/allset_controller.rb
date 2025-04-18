# frozen_string_literal: true

# The AllsetController handles CRUD operations for workout sets (Allset model).
# It ensures that users can only manage their own sets and provides feedback
# through flash messages and redirects.
class AllsetController < ApplicationController
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

    if @workout.save
      # Query sets after saving the new set
      @sets = @exercise.sets.order(created_at: :desc)
      @setss = @sets.group_by { |set| set.created_at.beginning_of_day }.sort_by { |date, _| date }.reverse

      respond_to do |format|
        format.html { redirect_to allset_path(@exercise.id), notice: t('allset.create.success') }
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace('rest-timer', partial: 'allset/sets_list', locals: { sets: @sets, setss: @setss }),
            turbo_stream.replace('empty-sets-message', partial: 'allset/empty_sets_message', locals: { sets: @sets })
          ]
        end
      end
    else
      # Query sets even on error to show current state
      @sets = @exercise.sets.order(created_at: :desc)
      @setss = @sets.group_by { |set| set.created_at.beginning_of_day }.sort_by { |date, _| date }.reverse

      respond_to do |format|
        format.html { redirect_to allset_path(@exercise.id), alert: t('allset.create.error') }
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace('rest-timer', partial: 'allset/sets_list', locals: { sets: @sets, setss: @setss }),
            turbo_stream.replace('empty-sets-message', partial: 'allset/empty_sets_message', locals: { sets: @sets })
          ], status: :unprocessable_entity
        end
      end
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
    Rails.logger.info "Destroy action called with params: #{params.inspect}"
    @workout = Allset.find(params[:id])
    Rails.logger.info "Found workout: #{@workout.inspect}"

    if current_user.id == @workout.user_id
      @exercise = Exercise.find(@workout.exercise_id)
      Rails.logger.info "Found exercise: #{@exercise.inspect}"

      if @workout.destroy
        Rails.logger.info 'Workout successfully destroyed'
        @sets = @exercise.sets.order(created_at: :desc)
        @setss = @sets.group_by { |set| set.created_at.beginning_of_day }.sort_by { |date, _| date }.reverse

        respond_to do |format|
          format.html do
            Rails.logger.info 'Rendering HTML response'
            redirect_to allset_path(@exercise.id), notice: 'Set was successfully deleted.'
          end
          format.turbo_stream do
            Rails.logger.info 'Rendering Turbo Stream response'
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
