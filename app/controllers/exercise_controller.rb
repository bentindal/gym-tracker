class ExerciseController < ApplicationController
  def index
    @exercises = Exercise.all
  end
  def view
    @exercise = Exercise.find(params[:id])
  end
  
  def new
    @exercise = Exercise.new(exercise_params)
    @exercise.save
    redirect_to exercises_url
  end

  def destroy
    @exercise = Exercise.find(params[:id])
    @exercise.destroy
    redirect_to exercises_url
  end

  private
    # Only allow a list of trusted parameters through.
    def exercise_params
      params.permit(:user_id, :name, :unit, :group)
    end
  
  end
