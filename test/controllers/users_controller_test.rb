
require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest

  def setup
    @user_one = users(:user_one)
    @user_two = users(:user_two)
  end

  test "should redirect to index when not logged in" do
    get users_path
    assert_redirected_to login_url
  end

  test "should get new" do
    get signup_path
    assert_response :success
  end

  test "should redirect edit when not logged in" do
    get edit_user_path(user_one)
    assert_redirected_to login_url
    assert_not flash.empty?
  end

  test "should redirect update when not logged in" do
    patch user_path(user_one), params: { user: { name:  user_one.name,
                                                 email: user_one.email }}
    assert_redirected_to login_url
    assert_not flash.empty?
  end

  test "users can only edit their own data" do
    log_in_as(user_one)
    get edit_user_path(user_two)
    assert_redirected_to root_url
    assert flash.empty?
  end

  test "users can only update their own data" do
    log_in_as(user_one)
    patch user_path(user_two), params: { user: { name:  user_one.name,
                                                 email: user_one.email }}
    assert_redirected_to root_url
    assert flash.empty?
  end

  test "admin attribute should not be exposed to change externally" do
    log_in_as(user_two)
    assert_not user_two.admin?
    patch user_path(user_two),  params: {
                                  user: { password:               "",
                                          password_confirmation:  "",
                                          admin: true }}
    assert_not user_two.reload.admin?
  end

  test "should redirect destroy when not logged in" do
    assert_no_difference "User.count" do
      delete user_path(user_two)
    end
    assert_redirected_to login_url
  end

  test "should redirect destroy when not admin" do
    log_in_as(user_two)
    assert_no_difference "User.count" do
      delete user_path(user_one)
    end
    assert_redirected_to root_url
  end

  test "should destroy when admin" do
    log_in_as(user_one)
    assert_difference "User.count", -1 do
      delete user_path(user_two)
    end
    assert_redirected_to users_path
    follow_redirect!
    assert_not flash.empty?
  end

  private
    attr_reader :user_one, :user_two
end
