class UsersController < ApplicationController
    def view
        @user = User.find(params[:id])
        @exercises = Exercise.where(user_id: params[:id])
        @workouts = Workout.where(user_id: params[:id])
        @is_friend = false
        @pending = false
        if current_user != nil
            all_friends = Friend.where(user: current_user.id)
            all_friends.each do |friend|
                if friend.follows == params[:id].to_i && friend.confirmed == true
                    @is_friend = true
                end
                if friend.follows == params[:id].to_i && friend.confirmed == false
                    @pending = true
                end
            end
        end
        # do they follow back?
        @follows_back = false
        if current_user != nil
            all_friends = Friend.where(follows: current_user.id)
            all_friends.each do |friend|
                if friend.user == params[:id].to_i && friend.confirmed == true
                    @follows_back = true
                end
            end
        end
    end
    def find
        @users = User.all
    end
end
