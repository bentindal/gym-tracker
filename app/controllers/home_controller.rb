class HomeController < ApplicationController
  def index
    @page_title = "Home"
    @page_description = "GymTracker is a simple easy-to-use workout tracker allowing you to track your workouts, follow your friends, and see what they're up to."
  end
end
