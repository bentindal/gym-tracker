# frozen_string_literal: true

class ExerciseController < ApplicationController
  def list
    @page_title = 'Recent Exercises'
    @page_description = 'View all your exercises on GymTracker'
    @exercises = Exercise.where(user_id: current_user.id)

    # Sort by last set
    @exercises = @exercises.order(:last_set).reverse_order
    # Get all unique group names
    @groups = @exercises.pluck(:group).uniq
    return unless params[:group]

    @exercises = @exercises.where(group: params[:group])
    # Sort by last set
    @exercises = @exercises.order(:last_set)
  end

  def view
    @exercise = Exercise.find(params[:id])
    if @exercise.user_id == current_user.id
      if @exercise.sets.count.positive?
        params[:from] = @exercise.sets.order(:created_at).first.created_at.strftime('%d/%m/%Y') if params[:from].nil?
        params[:to] = @exercise.sets.order(:created_at).last.created_at.strftime('%d/%m/%Y') if params[:to].nil?
      else
        params[:from] = DateTime.now.strftime('%d/%m/%Y')
        params[:to] = DateTime.now.strftime('%d/%m/%Y')
      end
    else
      redirect_to '/error/permission'
    end
  end

  def new
    @exercise = Exercise.new
  end

  def create
    @exercise = Exercise.new(exercise_params)

    if @exercise.save
      redirect_to allset_path(@exercise), notice: 'Exercise created successfully!'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @exercise = Exercise.find(params[:id])
  end

  def update
    @exercise = Exercise.find(params[:id])
    if current_user.id == @exercise.user_id
      if @exercise.update(exercise_params)
        redirect_to '/exercises', notice: 'Exercise updated successfully'
      else
        puts @exercise.errors.full_messages # Output error messages to the console
        redirect_to edit_exercise_path(@exercise), notice: 'Error updating exercise'
      end
    else
      redirect_to '/error/permission'
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

  def exercise_params
    params.require(:exercise).permit(:user_id, :name, :unit, :group)
  end
end
