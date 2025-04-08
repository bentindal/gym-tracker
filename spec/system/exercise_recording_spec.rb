# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Exercise Recording', type: :system do
  let(:user) { create(:user) }

  before do
    driven_by(:selenium_chrome_headless)
    user
  end

  it 'allows user to log in and record an exercise' do
    visit '/'
    
    # Find and click the Get Started link
    find('a', text: 'Get Started', match: :first).click
    
    # Login
    fill_in 'Email', with: user.email
    fill_in 'Password', with: 'password'
    click_button 'Log in'

    expect(page).to have_content('Signed in successfully')

    # Navigate to exercises page
    click_link 'Exercises'
    click_link 'Add New'

    # Fill in exercise details
    fill_in 'exercise[name]', with: 'Bench Press'
    select 'lbs', from: 'exercise[unit]'
    select 'Chest', from: 'exercise[group]'
    click_button 'Create'

    # Verify success and exercise details
    expect(page).to have_content('Success!')
    expect(page).to have_content('Bench Press')
    expect(page).to have_content('Chest')

    # Get the created exercise
    exercise = Exercise.find_by(name: 'Bench Press')
    expect(exercise).to be_present

    # Record a set
    # Check for correct field identification - might need to adjust these selectors
    fill_in 'weight', with: '225'
    fill_in 'repetitions', with: '10'
    click_button 'Add Set'
    
    # Wait for AJAX if necessary
    expect(page).to have_content('225')
    expect(page).to have_content('10')

    # Give database time to update
    sleep(1)
    
    # Verify the set was added to the database
    # Use the exercise ID to find the associated set
    set = Allset.find_by(exercise_id: exercise.id)
    
    # Debugging assistance - uncomment if needed
    # puts "Exercise: #{exercise.inspect}"
    # puts "Sets: #{Allset.all.inspect}"
    
    expect(set).to be_present
    expect(set.weight).to eq(225.0)
    expect(set.repetitions).to eq(10)
  end
end
