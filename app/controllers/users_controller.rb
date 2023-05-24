class UsersController < ApplicationController
    def view
        @user = User.find(params[:id])
        @exercises = Exercise.where(user_id: params[:id])
        @workouts = Workout.where(user_id: params[:id])
        @is_friend = false
        if current_user != nil
            all_friends = Friend.where(user: current_user.id)
            all_friends.each do |friend|
                if friend.follows == params[:id].to_i
                    @is_friend = true
                end
            end
        end
    end
    def find
        @users = User.all
    end
end
