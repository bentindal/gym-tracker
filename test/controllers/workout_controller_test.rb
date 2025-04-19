# frozen_string_literal: true

require 'test_helper'

class WorkoutControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:one)
    @other_user = users(:two)
    @workout = workouts(:one)
    sign_in @user
  end

  test 'should get list' do
    get workout_list_url
    assert_response :success
  end

  test 'should soft delete workout and redirect to workout view' do
    assert_nil @workout.deleted_at, 'Workout should not be deleted initially'

    delete workout_destroy_path(id: @workout.id)

    @workout.reload
    assert_not_nil @workout.deleted_at, 'Workout should be soft deleted'
    assert_redirected_to workout_view_path(@workout)
    assert_equal 'Workout was successfully deleted.', flash[:notice]
  end

  test 'should not allow other users to delete workout' do
    sign_out @user
    sign_in @other_user

    delete workout_destroy_path(id: @workout.id)

    @workout.reload
    assert_nil @workout.deleted_at, 'Workout should not be deleted by other user'
    assert_redirected_to permission_error_path
  end

  test 'should show deleted workout with appropriate message' do
    @workout.update(deleted_at: Time.current)

    get workout_view_path(id: @workout.id)

    assert_response :success
    assert_select 'h4.alert-heading', 'Workout Deleted'
    assert_select 'a.btn', 'Return to Dashboard'
  end

  test 'should not show AI analysis for deleted workout' do
    @workout.update(deleted_at: Time.current)
    @workout.create_workout_analysis(feedback: 'Test analysis')

    get workout_view_path(id: @workout.id)

    assert_response :success
    assert_select '.card-header', { count: 0, text: 'AI Analysis' }
  end
end
