# frozen_string_literal: true

require 'test_helper'

class WorkoutControllerTest < ActionDispatch::IntegrationTest
  test 'should get list' do
    get workout_list_url
    assert_response :success
  end
end
