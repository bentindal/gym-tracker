class HomeController < ApplicationController
  def index
    @page_title = "Home"
    @page_description = "Digital Gym Workout Tracker. Track your workouts & follow your friends to see what they are up to."
  end
end
