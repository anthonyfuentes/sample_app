
require "test_helper"

class UserSignupTest < ActionDispatch::IntegrationTest

  @@invalid_params = { user: { name:  "",
                               email: "woo!",
                               password:              "foo",
                               password_confirmation: "nar" }}
  @@valid_params = { user: { name:  "User",
                             email: "user@example.com",
                               password:              "password123",
                               password_confirmation: "password123" }}

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
    assert_template "users/show"
    assert is_logged_in?
  end

  test "success flash should appear on successful signup redirect" do
    post signup_path, @@valid_params
    follow_redirect!
    assert_not flash.empty?
  end
end
