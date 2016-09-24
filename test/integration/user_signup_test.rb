
require "test_helper"

class UserSignupTest < ActionDispatch::IntegrationTest

  @@invalid_params = { user: { name:  "",
                               email: "woo!",
                               password:              "foo",
                               password_confirmation: "nar" }}
  @@valid_params = { user: {   name:  "User",
                               email: "user@example.com",
                               password:              "password123",
                               password_confirmation: "password123" }}

  def setup
    ActionMailer::Base.deliveries.clear
  end

  test "user not created from submission of invalid data" do
    assert_no_difference "User.count" do
      post signup_path, @@invalid_params
    end
    assert_template "users/new"
  end

  test "error messages appear for failed signup" do
    post signup_path, @@invalid_params
    assert_select "div#error_explanation"
    assert_select "div.alert-danger"
    assert_select "ul.error_list" do
    assert_select "li", 4
    end
  end

  test "form should post to signup_path" do
    get signup_path
    assert_select "form[action='/signup']"
  end

  test "user created from submission of valid data" do
    assert_difference "User.count", 1 do
      post signup_path, @@valid_params
    end
    follow_redirect!
    assert_template "static_pages/home"
    assert_not flash.empty?
  end

  test "activation required following submission of valid data" do
    post signup_path, @@valid_params
    assert_equal 1, ActionMailer::Base.deliveries.size
    user = assigns(:user)
    assert_not user.activated?
    log_in_as(user)
    assert_not is_logged_in?
  end

  test "activation credential verification" do
    post signup_path, @@valid_params
    user = assigns(:user)
    # Invalid activation token
    get edit_account_activation_path("invalid token", email: user.email)
    assert_not is_logged_in?
    # Valid token, wrong email
    get edit_account_activation_path(user.activation_token, email: 'wrong')
    assert_not is_logged_in?
    # Valid activation token
    get edit_account_activation_path(user.activation_token, email: user.email)
    assert user.reload.activated?
  end

  test "user logged in and redirected on successful activation" do
    post signup_path, @@valid_params
    user = assigns(:user)
    get edit_account_activation_path(user.activation_token, email: user.email)
    follow_redirect!
    assert_template "users/index"
    assert is_logged_in?
  end
end
