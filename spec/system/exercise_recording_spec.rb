require 'rails_helper'

RSpec.describe 'Exercise Recording', type: :system do
  let(:user) { create(:user) }

  it 'allows user to log in and record an exercise' do
    visit root_path
    
    # Login
    first(:link, 'Get Started').click
    fill_in 'Email', with: user.email
    fill_in 'Password', with: 'password' # Assuming this is the test password
    click_on 'Log in'
    
    expect(page).to have_text('Signed in successfully')
    
    # Navigate to exercises page
    click_on 'Exercises'
    
    # Create new exercise
    click_on 'Add New'
    
    # Fill in exercise details
    fill_in 'exercise[name]', with: 'Bench Press'
    select 'lbs', from: 'exercise[unit]'
    select 'Chest', from: 'exercise[group]'
    click_on 'Create'
    
    # Verify exercise was created
    expect(page).to have_text('Exercise created successfully')
    expect(page).to have_text('Bench Press')

    # Record a set
    fill_in 'weight', with: '225'
    fill_in 'repetitions', with: '10'
    click_on 'Add Set'
    
    # Verify the set was added to the database
    exercise = Exercise.last
    set = Allset.last
    
    expect(set.weight).to eq(225.0)
    expect(set.repetitions).to eq(10)
    expect(set.exercise_id).to eq(exercise.id)
  end
end 