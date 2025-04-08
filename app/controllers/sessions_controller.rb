# frozen_string_literal: true

# The SessionsController manages user login sessions, providing the interface
# for users to sign in to GymTracker.
class SessionsController < ApplicationController
  def new
    @page_title = t('.page_title')
    @page_description = t('.page_description')
  end
end
