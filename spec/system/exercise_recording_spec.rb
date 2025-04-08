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

    # Verify set was recorded
    expect(page).to have_text('Set added successfully')
    expect(page).to have_text('225.0lbs x 10')
  end
end 