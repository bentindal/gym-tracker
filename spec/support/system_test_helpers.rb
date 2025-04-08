def login_as(user)
  visit login_path
  fill_in 'Email', with: user.email
  fill_in 'Password', with: user.password
  click_button 'Log in'
end

def create_exercise_record(exercise_params)
  visit new_exercise_record_path
  fill_in 'Exercise Name', with: exercise_params[:name]
  fill_in 'Duration', with: exercise_params[:duration]
  click_button 'Create Exercise Record'
end