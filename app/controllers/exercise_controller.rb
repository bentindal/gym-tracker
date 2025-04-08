# frozen_string_literal: true

# The ExerciseController manages CRUD operations for exercises, allowing users
# to create, view, update, and delete their workout exercises.
class ExerciseController < ApplicationController
  def list
    set_page_metadata('Recent Exercises', 'View all your exercises on GymTracker')
    load_exercises
    filter_exercises_by_group if params[:group].present?
  end

  def view
    @exercise = Exercise.find(params[:id])
    if authorized_user?(@exercise.user_id)
      set_date_range
    else
      redirect_to permission_error_path
    end
  end

  def new
    @exercise = Exercise.new
  end

  def edit
    @exercise = Exercise.find(params[:id])
  end

  def create
    @exercise = Exercise.new(exercise_params)

    if @exercise.save
      redirect_to allset_path(@exercise), notice: t('.success')
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @exercise = Exercise.find(params[:id])

    if authorized_user?(@exercise.user_id)
      if @exercise.update(exercise_params)
        redirect_to exercises_path, notice: t('.success')
      else
        Rails.logger.error("Exercise update failed: #{@exercise.errors.full_messages}")
        redirect_to edit_exercise_path(@exercise), alert: t('.failure')
      end
    else
      redirect_to permission_error_path
    end
  end

  def destroy
    @exercise = Exercise.find(params[:id])
    if current_user.id == @exercise.user_id
      @exercise.destroy
      redirect_to exercises_url
    else
      redirect_to '/error/permission'
    end
  end

  private

  def set_page_metadata(title, description)
    @page_title = title
    @page_description = description
  end

  def load_exercises
    @exercises = Exercise.where(user_id: current_user.id).order(last_set: :desc)
    @groups = @exercises.pluck(:group).uniq
  end

  def filter_exercises_by_group
    @exercises = @exercises.where(group: params[:group]).order(last_set: :desc)
  end

  def set_date_range
    if @exercise.sets.exists?
      @from = @exercise.sets.order(:created_at).first.created_at.to_date
      @to = @exercise.sets.order(:created_at).last.created_at.to_date
    else
      today = Time.zone.today
      @from = today
      @to = today
    end
  end

  def authorized_user?(user_id)
    current_user.id == user_id
  end

  def permission_error_path
    '/error/permission'
  end

  def allset_path(exercise)
    "/allset/#{exercise.id}"
  end

  def exercises_path
    '/exercises'
  end

  def exercise_params
    params.require(:exercise).permit(:user_id, :name, :unit, :group)
  end
end
