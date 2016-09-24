
require 'test_helper'

class UsersIndexTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:user_one)
  end

  test "users index paginates list of active users for logged in users" do
    log_in_as(users(:user_two))
    get users_path
    assert_template "users/index"
    assert_select "div.pagination"
    User.paginate(page: 1).each do |user|
      assert_presence_by_activation_status(user)
    end
  end

  test "users index shows all users with delete link and status for admins" do
    log_in_as(user)
    get users_path
    User.paginate(page: 1).each do |user|
      unless user.admin?
        assert_select "a[href=?]", user_path(user), text: "remove"
        if !user.activated
          assert_select "span", :text => /\d+ days? un-activated/
        end
      end
    end
  end

  private
    attr_reader :user

    # asserts presence of html element based on activation status of user
    def assert_presence_by_activation_status(user)
      if user.activated?
        assert_select "a[href=?]", user_path(user), text: user.name
      else
        assert_select "a[href=?]", user_path(user), text: user.name, count: 0
      end
    end

end
