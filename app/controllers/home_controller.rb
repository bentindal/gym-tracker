# frozen_string_literal: true

# The HomeController manages the landing page for GymTracker. It redirects
# signed-in users to their dashboard and displays information for new visitors.
class HomeController < ApplicationController
  def index
    redirect_to dashboard_path if user_signed_in?

    @page_title = "Free Online Gym Tracker & Workout Diary"
    @page_description = t('.page_description')
    @block_mobile_nav_bar = true
  end
end
