# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Exercise Recording' do
  let(:user) { create(:user) }
  let(:exercise) { create(:exercise, name: 'Bench Press', user: user) }

  before do
    user
    exercise
    sign_in_user
  end

  describe 'exercise creation' do
    before do
      navigate_to_exercises
      click_link('Add New')
      fill_in_exercise_details
      click_button 'Create'
    end

    it 'displays the new exercise name' do
      expect(page).to have_css('h2.display-5', text: 'Bench Press')
    end

    it 'creates the exercise in the database' do
      expect(Exercise.find_by(name: 'Bench Press')).to be_present
    end
  end

  describe 'set recording' do
    before do
      navigate_to_exercises
      click_link('Bench Press')
      fill_in 'weight', with: '225'
      fill_in 'repetitions', with: '10'
      click_button 'Add Set'
    end

    it 'displays the set details' do
      within('table.table') do
        expect(page).to have_content('225.0lbs x 10')
      end
    end
  end

  private

  def sign_in_user
    visit '/users/sign_in'
    within('#new_user') do
      fill_in 'user_email', with: user.email
      fill_in 'user_password', with: 'password'
      click_button 'Log in'
    end
    expect(page).to have_css('.alert-success', text: /Success.*signed in successfully/i)
  end

  def navigate_to_exercises
    within('.navbar-nav') do
      click_link('Exercises')
    end
  end

  def fill_in_exercise_details
    fill_in 'exercise[name]', with: 'Bench Press'
    select 'lbs', from: 'exercise[unit]'
    select 'Chest', from: 'exercise[group]'
  end
end
