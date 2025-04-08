# frozen_string_literal: true

class HomeController < ApplicationController
  def index
    # If users signed in redirect to dashboard
    redirect_to dashboard_path if user_signed_in?
    @page_title = 'Free Online Gym Tracker & Workout Diary'
    @page_description = "GymTracker is a simple easy-to-use gym tracker & workout diary allowing you to track your workouts, follow your friends, and see what they're up to."
    @block_mobile_nav_bar = true
  end
end
