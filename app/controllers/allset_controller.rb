class AllsetController < ApplicationController
  def show
    @exercise = Exercise.find(params[:id]) # Use exercise_id instead of params[:id]
    if current_user.id == @exercise.user_id  # Check if current user is the owner of the exercise
      @page_title = @exercise.name + " | Workout"
      @sets = Allset.where(exercise_id: @exercise.id) # Filter by exercise_id
      @sets = @sets.order(created_at: :desc)
      # Sort sets by uniq date
      @setss = @sets.group_by { |set| set.created_at.to_date }
    else
      redirect_to "/error/permission"
    end
  end

  def create
    # Ensure we get the parameters - convert string values to numbers if needed
    repetitions = params[:repetitions].to_i if params[:repetitions].present?
    weight = params[:weight].to_f if params[:weight].present?
    
    @workout = Allset.new(
      exercise_id: params[:exercise_id],
      user_id: params[:user_id],
      repetitions: repetitions,
      weight: weight,
      isFailure: params[:isFailure] == "on",
      isDropset: params[:isDropset] == "on",
      isWarmup: params[:isWarmup] == "on"
    )

    if @workout.save
      # Update last_set on exercise
      @exercise = Exercise.find(params[:exercise_id])
      @exercise.last_set = @workout.created_at
      @exercise.save
      redirect_to "/allset/" + params[:exercise_id].to_s, notice: "Set added successfully!"
    else
      # Log validation errors for debugging
      Rails.logger.error("Allset save failed: #{@workout.errors.full_messages}")
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @workout = Allset.find(params[:id])
  end

  def update
    @workout = Allset.find(params[:id])
    if current_user.id == @workout.user_id
      if @workout.update(allset_params2)
        redirect_to "/allset/#{@workout.exercise_id}", notice: "Set was successfully updated!"
      else
        puts @workout.errors.full_messages # Output error messages to the console
        redirect_to edit_allset_path(@workout), notice: "Error updating set"
      end
    else
      redirect_to "/error/permission"
    end
  end

  def destroy
    @workout = Allset.find(params[:id])
    if current_user.id == @workout.user_id
      @id = @workout.exercise_id
      @workout.destroy
      redirect_to "/allset/#{@id.to_s}", notice: "Workout was successfully destroyed."
    else
      redirect_to "/error/permission"
    end
  end

  private

  def allset_params
    params.permit(:exercise_id, :user_id, :repetitions, :weight, :isFailure, :isDropset, :isWarmup)
  end
  def allset_params2
    params.require(:allset).permit(:exercise_id, :user_id, :repetitions, :weight, :isFailure, :isDropset, :isWarmup)
  end
  
    
end
