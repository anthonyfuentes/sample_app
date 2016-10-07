
require 'test_helper'

class FollowingTest < ActionDispatch::IntegrationTest

  def setup
    @user_one = users(:user_one)
    @user_two = users(:user_two)
    log_in_as(user_one)
  end

  test "following page" do
    get following_user_path(user_one)
    assert_template "show_follow"
    assert_not user_one.following.empty?
    assert_match user_one.following.count.to_s, response.body
    user_one.following.each { |user| assert_select "a[href=?]", user_path(user) }
  end

  test "followers page" do
    get following_user_path(user_one)
    assert_template "show_follow"
    assert_not user_one.followers.empty?
    assert_match user_one.followers.count.to_s, response.body
    user_one.followers.each { |user| assert_select "a[href=?]", user_path(user) }
  end

  test "should follow a user the standard way" do
    assert_difference 'user_one.following.count', 1 do
      post relationships_path, params: { followed_id: user_two.id }
    end
  end

  test "should follow a user with Ajax" do
    assert_difference 'user_one.following.count', 1 do
      post relationships_path, xhr: true, params: { followed_id: user_two.id }
    end
  end

  test "should unfollow a user the standard way" do
    user_one.follow(user_two)
    relationship = user_one.active_relationships.find_by(followed_id: user_two.id)
    assert_difference 'user_one.following.count', -1 do
      delete relationship_path(relationship)
    end
  end

  test "should unfollow a user with Ajax" do
    user_one.follow(user_two)
    relationship = user_one.active_relationships.find_by(followed_id: user_two.id)
    assert_difference 'user_one.following.count', -1 do
      delete relationship_path(relationship), xhr: true
    end
  end

  private
    attr_reader :user_one, :user_two
end
