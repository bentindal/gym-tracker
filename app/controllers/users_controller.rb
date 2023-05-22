class UsersController < ApplicationController
    def view
        @user = User.find(params[:id])
        @exercises = Exercise.where(user_id: params[:id])
        @workouts = Workout.where(user_id: params[:id])

    end
end
