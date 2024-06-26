class UsersController < ApplicationController
    def view
        @user = User.find(params[:id])
        @location = "dashboard"
        
        userList = [@user]
    
        @feed = Workout.where(user_id: userList).order(:started_at).reverse_order[0...3]

        @exercises = Exercise.where(user_id: params[:id])
        @workouts = Allset.where(user_id: params[:id])
        @is_friend = false
        @pending = false
        @page_title = @user.first_name + " " + @user.last_name + "'s Profile"
        @page_description = "View " + @user.first_name + " " + @user.last_name + "'s profile on GymTracker"
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
        # Now for calendar view, default = current month
        if params[:month] != nil && params[:month].to_i > 0 && params[:month].to_i < 13 && params[:year] != nil && params[:year].to_i > 2020 && params[:year].to_i < 3000
            # If month is specified
            @month = params[:month].to_i
            @year = params[:year].to_i
        else
            @month = Date.today.month
            @year = Date.today.year
        end
        # Month name @month
        @month_name = Date::MONTHNAMES[@month]
        
    end
    def find
        @page_title = "All Users"
        @page_description = "View all users using GymTracker"
        @users = User.all
        # Sort Alphabetically by First Name
        @users = @users.sort_by { |user| user.first_name }
    end
end
