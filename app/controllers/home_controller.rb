class HomeController < ApplicationController
  def index
    # If users signed in redirect to dashboard
    if user_signed_in?
      redirect_to dashboard_path
    end
    @page_title = "Free Online Gym Tracker & Workout Log"
    @page_description = "GymTracker is a simple easy-to-use gym tracker & workout log allowing you to track your workouts, follow your friends, and see what they're up to."
  end
end
