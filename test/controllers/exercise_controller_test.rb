# frozen_string_literal: true

require 'test_helper'

class ExerciseControllerTest < ActionDispatch::IntegrationTest
  test 'should get new' do
    get exercise_new_url
    assert_response :success
  end

  test 'should get create' do
    get exercise_create_url
    assert_response :success
  end
end
