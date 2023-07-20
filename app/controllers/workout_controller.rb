class WorkoutController < ApplicationController
  def show
    @exercise = Exercise.find(params[:id]) # Use exercise_id instead of params[:id]
    if current_user.id == @exercise.user_id  # Check if current user is the owner of the exercise
      @page_title = @exercise.name + " | Workout"
      @sets = Workout.where(exercise_id: @exercise.id) # Filter by exercise_id
      @sets = @sets.order(created_at: :desc)
    else
      redirect_to "/error/permission"
    end
  end

  def create
    @workout = Workout.new(workout_params)

    if @workout.save
      redirect_to "/workout/" + params[:exercise_id].to_s, notice: "Set added successfully!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @workout = Workout.find(params[:id])
  end

  def update
    @workout = Workout.find(params[:id])
    if current_user.id == @workout.user_id
      if @workout.update(workout_params2)
        redirect_to "/workout/#{@workout.exercise_id}", notice: "Set was successfully updated!"
      else
        puts @workout.errors.full_messages # Output error messages to the console
        redirect_to edit_workout_path(@workout), notice: "Error updating set"
      end
    else
      redirect_to "/error/permission"
    end
  end

  def destroy
    @workout = Workout.find(params[:id])
    if current_user.id == @workout.user_id
      @id = @workout.exercise_id
      @workout.destroy
      redirect_to "/workout/#{@id.to_s}", notice: "Workout was successfully destroyed."
    else
      redirect_to "/error/permission"
    end
  end

  private

  def workout_params
    params.permit(:exercise_id, :user_id, :repetitions, :weight, :isFailure, :isDropset, :isWarmup)
  end
  def workout_params2
    params.require(:workout).permit(:exercise_id, :user_id, :repetitions, :weight, :isFailure, :isDropset, :isWarmup)
  end
  
    
end
