# frozen_string_literal: true

require 'test_helper'

class FriendControllerTest < ActionDispatch::IntegrationTest
  test 'should get index' do
    get friend_index_url
    assert_response :success
  end

  test 'should get add' do
    get friend_add_url
    assert_response :success
  end

  test 'should get remove' do
    get friend_remove_url
    assert_response :success
  end
end
