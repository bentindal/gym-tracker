class LikesController < ApplicationController
    def create
        if Like.where(user_id: current_user.id, workout_id: params[:workout_id]).count == 0
            @like = Like.new
            @like.user_id = current_user.id
            @like.workout_id = params[:workout_id]
            @like.name = current_user.first_name + " " + current_user.last_name
            @like.save
            redirect_to "/workout/view?id=#{params[:workout_id]}"
        else
            Like.where(user_id: current_user.id, workout_id: params[:workout_id]).destroy_all

            redirect_to "/workout/view?id=#{params[:workout_id]}"
        end
    end
end
