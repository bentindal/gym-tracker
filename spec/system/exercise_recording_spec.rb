# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Exercise Recording', type: :system do
  let(:user) { create(:user) }

  before do
    # Use Rack::Test driver which is more stable for basic tests
    driven_by(:rack_test)
    user
  end

  it 'allows user to log in and record an exercise' do
    # Visit sign-in page directly
    visit '/users/sign_in'

    # Fill in login details with explicit identification
    within('#new_user') do
      fill_in 'user_email', with: user.email
      fill_in 'user_password', with: 'password'
      click_button 'Log in'
    end

    # Verify login success using the exact HTML content
    expect(page).to have_css('.alert-success', text: /Success.*signed in successfully/i)

    # Navigate to exercises page using a more specific selector for the navbar link
    within('.navbar-nav') do
      click_link('Exercises')
    end

    # Click Add New button - using click_link instead of find
    click_link('Add New')

    # Fill in exercise details with explicit field identification
    fill_in 'exercise[name]', with: 'Bench Press'
    select 'lbs', from: 'exercise[unit]'
    select 'Chest', from: 'exercise[group]'
    click_button 'Create'

    # Look for heading with display-5 class containing "Bench Press"
    expect(page).to have_css('h2.display-5', text: 'Bench Press')

    # Get the created exercise from database
    exercise = Exercise.find_by(name: 'Bench Press')
    expect(exercise).to be_present

    # Record a set with correct field names from the HTML
    fill_in 'weight', with: '225'
    fill_in 'repetitions', with: '10'
    click_button 'Add Set'

    # Verify the set was added to the database
    set = Allset.last
    expect(set.weight).to eq(225.0)
    expect(set.repetitions).to eq(10)
    expect(set.exercise_id).to eq(exercise.id)
  end
end
