
require 'test_helper'

class UsersLoginTest < ActionDispatch::IntegrationTest


  def setup
    @user = users(:user_one)
  end

  test "login form renders correctly" do
    get login_path
    assert_template 'sessions/new'
  end

  test "unsuccessful login (w/ invalid information)" do
    log_in_as(user, password: "")
    assert_template 'sessions/new'
    assert_not is_logged_in?
    assert_not flash.empty?
    get root_path
    assert flash.empty?
  end

  test "successful login (w/ valid information)" do
    get login_path
    log_in_as(user)
    assert is_logged_in?
    assert_redirected_to user
    follow_redirect!
    assert_template 'users/show'
    assert_select "a[href=?]", login_path, count: 0
    assert_select "a[href=?]", logout_path
    assert_select "a[href=?]", user_path(user)
  end

  test "logout including multi-window scenario" do
    log_in_as(user)
    delete logout_path
    assert_not is_logged_in?
    assert_redirected_to root_url
    # simulate user logging out from second window
    delete logout_path
    follow_redirect!
    assert_select "a[href=?]", login_path
    assert_select "a[href=?]", logout_path,       count: 0
    assert_select "a[href=?]", user_path(user),  count: 0
  end

  test "test login w/ remember selected" do
    log_in_as(user, remember_me: "1")
    assert_equal assigns(:user).remember_token.to_s, cookies["remember_token"].to_s
  end

  test "test login w/o remember selected" do
    log_in_as(user, remember_me: "0")
    assert_nil cookies["remember_token"]
  end

  private

    attr_reader :user, :valid_params, :invalid_params
end
