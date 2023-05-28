class ExerciseController < ApplicationController
  def index
    @exercises = Exercise.where(user_id: current_user.id)
  end

  def view
    redirect_to "/exercise/#{params[:id]}"
  end
  
  def new
    @exercise = Exercise.new
  end
  

  def create
    if current_use.id == exercise_params[:user_id]
      @exercise = Exercise.new(exercise_params)
    
      if @exercise.save
        redirect_to "/", notice: "Exercise created successfully!"
      else
        render :new, status: :unprocessable_entity
      end
    else
      redirect_to "/error/permission"
    end
  end
  

  def edit
    @exercise = Exercise.find(params[:id])
  end

  def update
    @exercise = Exercise.find(params[:id])
    if current_user.id == @exercise.user_id
      if @exercise.update(exercise_params)
        redirect_to "/", notice: "Exercise updated successfully"
      else
        puts @exercise.errors.full_messages # Output error messages to the console
        redirect_to edit_exercise_path(@exercise), notice: "Error updating exercise"
      end
    else
      redirect_to "/error/permission"
    end
  end
  

  def destroy
    @exercise = Exercise.find(params[:id])
    if current_user.id == @exercise.user_id
      @exercise.destroy
      redirect_to exercises_url
    else
      redirect_to "/error/permission"
    end
  end

  private
    def exercise_params
      params.require(:exercise).permit(:user_id, :name, :unit, :group)
    end
  
end
