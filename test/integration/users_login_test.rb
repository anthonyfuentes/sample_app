
require 'test_helper'

class UsersLoginTest < ActionDispatch::IntegrationTest


  def setup
    @user = users(:user_one)
    @invalid_params = { session: {  email:    "user@example.com",
                                    password: "password123" }}
    @valid_params =   { session: {  email: @user.email,
                                    password: "password" }}
  end

  test "login form renders correctly" do
    get login_path
    assert_template 'sessions/new'
  end

  test "unsuccessful login (w/ invalid information)" do
    post login_path, invalid_params
    assert_template 'sessions/new'
    assert_not is_logged_in?
    assert_not flash.empty?
    get root_path
    assert flash.empty?
  end

  test "successful login (w/ valid information) followed by logout" do
    get login_path
    post login_path, valid_params
    assert is_logged_in?
    assert_redirected_to @user
    follow_redirect!
    assert_template 'users/show'
    assert_select "a[href=?]", login_path, count: 0
    assert_select "a[href=?]", logout_path
    assert_select "a[href=?]", user_path(@user)
    delete logout_path
    assert_not is_logged_in?
    assert_redirected_to root_url
    follow_redirect!
    assert_select "a[href=?]", login_path
    assert_select "a[href=?]", logout_path,       count: 0
    assert_select "a[href=?]", user_path(@user),  count: 0
  end

  private

    attr_reader :valid_params, :invalid_params
end
