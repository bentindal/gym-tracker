class WorkoutController < ApplicationController

  def show
    @exercise = Exercise.find(params[:id])
    @sets = Workout.where(exercise_id: params[:id])
    @sets = @sets.order(created_at: :desc)
    @workout = Workout.new
    
  end

  # POST /workouts
  def create
    @workout = Workout.new(workout_params)

    if @workout.save
      redirect_to "/workout/show?id="+params[:exercise_id].to_s, alert: "Set added successfully!."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /workouts/1
  def update
    if @workout.update(workout_params)
      redirect_to @workout, notice: "workout was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /workouts/1
  def destroy
    @workout = Workout.find(params[:id])
    @id = @workout.exercise_id
    @workout.destroy
    redirect_to "/workout/show?id="+@id.to_s, notice: "workout was successfully destroyed."
  end
  
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_workout
      @workout = workout.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def workout_params
      params.permit(:exercise_id, :user_id, :repetitions, :weight)
    end
  end
