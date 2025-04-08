require "application_system_test_case"

class ExerciseRecordingTest < ApplicationSystemTestCase
  setup do
    @user = users(:one) # Assuming you have a user fixture
  end

  test "user can log in and record an exercise" do
    visit root_path
    
    # Login
    click_on "Log in"
    fill_in "Email", with: @user.email
    fill_in "Password", with: "password" # Assuming this is the test password
    click_on "Log in"
    
    assert_text "Signed in successfully"
    
    # Navigate to new exercise
    click_on "New Exercise"
    
    # Fill in exercise details
    fill_in "Name", with: "Bench Press"
    fill_in "Sets", with: "3"
    fill_in "Reps", with: "10"
    fill_in "Weight", with: "225"
    click_on "Create Exercise"
    
    # Verify exercise was created
    assert_text "Exercise was successfully created"
    assert_text "Bench Press"
    assert_text "3 sets"
    assert_text "10 reps"
    assert_text "225 lbs"
  end
end 