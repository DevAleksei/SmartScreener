require 'test_helper'

class ScreenerControllerTest < ActionController::TestCase
  test "should get draw" do
    get :draw
    assert_response :success
  end

end
