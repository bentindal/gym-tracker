require "test_helper"

class FeedControllerTest < ActionDispatch::IntegrationTest
  test "should get view" do
    get feed_view_url
    assert_response :success
  end
end
