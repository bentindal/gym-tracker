require "test_helper"

class WorkoutControllerTest < ActionDispatch::IntegrationTest
  test "should get view" do
    get workout_view_url
    assert_response :success
  end
end
