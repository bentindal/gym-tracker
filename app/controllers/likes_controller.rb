# frozen_string_literal: true

# The LikesController manages the creation and removal of likes for workouts.
# It supports both HTML and JSON responses for updating the like count and
# providing feedback to the user.
class LikesController < ApplicationController
  def create
    workout = Workout.find(params[:workout_id])
    toggle_like(workout)

    respond_to do |format|
      format.html { handle_html_response }
      format.json { render_json_response(workout) }
    end
  end

  private

  def toggle_like(workout)
    like = Like.find_by(user_id: current_user.id, workout_id: workout.id)

    if like
      like.destroy
    else
      Like.create(user_id: current_user.id, workout_id: workout.id)
    end

    workout.reload
    log_like_details(workout)
  end

  def log_like_details(workout)
    Rails.logger.debug { "Liked by: #{workout.liked_by.inspect}" }
    Rails.logger.debug { "Likes count: #{workout.likes_count}" }
    Rails.logger.debug { "Current user: #{current_user.name}" }
  end

  def handle_html_response
    case params[:back]
    when 'dashboard'
      redirect_to dashboard_path
    when 'workout'
      redirect_to workout_path(params[:workout_id])
    else
      redirect_back(fallback_location: root_path)
    end
  end

  def render_json_response(workout)
    render json: {
      count: workout.likes_count,
      liked_by: workout.liked_by.compact
    }
  end
end
