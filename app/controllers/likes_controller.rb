# frozen_string_literal: true

class LikesController < ApplicationController
  def create
    workout = Workout.find(params[:workout_id])
    like = Like.find_by(user_id: current_user.id, workout_id: workout.id)

    if like
      like.destroy
    else
      Like.create(user_id: current_user.id, workout_id: workout.id)
    end

    workout.reload # Reload the workout
    liked_by = workout.liked_by # Get updated list

    # Add debugging
    Rails.logger.debug "Liked by: #{liked_by.inspect}"
    Rails.logger.debug "Likes count: #{workout.likes_count}"
    Rails.logger.debug "Current user: #{current_user.name}"

    respond_to do |format|
      format.html do
        case params[:back]
        when 'dashboard'
          redirect_to dashboard_path
        when 'workout'
          redirect_to workout_path(params[:workout_id])
        else
          redirect_back(fallback_location: root_path)
        end
      end
      format.json do
        render json: {
          count: workout.likes_count,
          liked_by: liked_by.compact
        }
      end
    end
  end
end
