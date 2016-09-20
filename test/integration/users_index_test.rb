
require 'test_helper'

class UsersIndexTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:user_one)
  end

  test "users index paginates list of users for logged in users" do
    log_in_as(user)
    get users_path
    assert_template "users/index"
    assert_select "div.pagination"
    User.paginate(page: 1).each do |user|
      assert_select "a[href=?]", user_path(user), text: user.name
    end
  end

  test "users index shows delete link for admins" do
    log_in_as(user)
    get users_path
    User.paginate(page: 1).each do |user|
      unless user.admin?
        assert_select "a[href=?]", user_path(user), text: "remove"
      end
    end
  end

  private
    attr_reader :user
end
