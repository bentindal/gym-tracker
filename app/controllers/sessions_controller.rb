class SessionsController < ApplicationController
    def new
        @page_title = "Sign In"
        @page_description = "Sign in to GymTracker to start tracking your workouts, following your friends, and seeing what they're up to."
    end
end
