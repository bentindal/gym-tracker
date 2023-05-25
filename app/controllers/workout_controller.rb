class WorkoutController < ApplicationController
  def show
    @exercise = Exercise.find(params[:id]) # Use exercise_id instead of params[:id]
    @sets = Workout.where(exercise_id: @exercise.id) # Filter by exercise_id
    @sets = @sets.order(created_at: :desc)
  end

  def create
    @workout = Workout.new(workout_params2)

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
    if @workout.update(workout_params)
      redirect_to "/workout/#{@workout.exercise_id}", notice: "Set was successfully updated!"
    else
      puts @workout.errors.full_messages # Output error messages to the console
      redirect_to edit_workout_path(@workout), notice: "Error updating set"
    end
  end

  def destroy
    @workout = Workout.find(params[:id])
    @id = @workout.exercise_id
    @workout.destroy
    redirect_to "/workout/#{@id.to_s}", notice: "Workout was successfully destroyed."
  end

  private

    def workout_params2
      params.permit(:exercise_id, :user_id, :repetitions, :weight)
    end
    def workout_params
      params.require(:workout).permit(:exercise_id, :user_id, :repetitions, :weight)
    end
    
end
