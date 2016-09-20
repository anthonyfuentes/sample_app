
require 'test_helper'

class UsersEditTest < ActionDispatch::IntegrationTest
  @@invalid_update_data = { user:  { name: "",
                                     email: "test",
                                     password:               "123",
                                     password_confirmation:  "456"} }

  @@name, @@email = "Foo", "foo@example.com"
  @@valid_update_data = { user:  {   name: @@name,
                                     email: @@email,
                                     password:               "",
                                     password_confirmation:  ""} }

  def setup
    @user = users(:user_one)
  end

  test "unsuccessful edit" do
    log_in_as(user)
    get edit_user_path(user)
    assert_template "users/edit"
    patch user_path(user), @@invalid_update_data
    assert_template "users/edit"
    assert_select "div.alert-danger", "The form contains 4 errors."
  end

  test "successful edit" do
    log_in_as(user)
    get edit_user_path(user)
    assert_template "users/edit"
    patch user_path(user), @@valid_update_data
    assert_redirected_to user
    assert_not flash.empty?
    user.reload
    assert_equal @@name, user.name
    assert_equal @@email, user.email
  end

  test "friendly forwarding" do
    get edit_user_path(user)
    log_in_as(user)
    assert_redirected_to edit_user_path(user)
    delete logout_path
    log_in_as(user)
    assert_redirected_to user
  end

  private
    attr_reader :user
end

