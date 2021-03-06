
require 'test_helper'

class UserTest < ActiveSupport::TestCase

  def setup
    @user = User.new(name: "Usu Ario", email: "usuario@ejemplo.com",
                      password: "foo123", password_confirmation: "foo123")
  end

  test "should be valid" do
    assert user.valid?
  end

  test "name should be present" do
    user.name = "    "
    assert_not user.valid?
  end

  test "name should not be too long" do
    user.name = "_" * 51
    assert_not user.valid?
  end

  test "email should be present" do
    user.email = ""
    assert_not user.valid?
  end

  test "email should not be too long" do
    user.email = " #{ "_" * 244}@ejemplo.com"
    assert_not user.valid?
  end

  test "email validation should accept valid addresses" do
    valid_addresses = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org
                         first.last@foo.jp alice+bob@baz.cn]
    valid_addresses.each do |valid_address|
      user.email = valid_address
      assert user.valid?, "#{ valid_address.inspect } should be valid"
    end
  end
  test "email validation should reject invalid addresses" do
    invalid_addresses = %w[user@example,com user_at_foo.org user.name@example.
                           foo@bar_baz.com foo@bar+baz.com, foo@bar..com]
    invalid_addresses.each do |invalid_address|
      user.email = invalid_address
      assert_not user.valid?, "#{ invalid_address.inspect } should be invalid"
    end
  end

  test "email addresses should be unique" do
    duplicate_user = user.dup
    duplicate_user.email.upcase!
    user.save
    assert_not duplicate_user.valid?
  end

  test "email addresses should be downcased for saving" do
    mixed_case_email = user.email = "USUariO@ejEMplo.com"
    user.save
    assert_equal(mixed_case_email.downcase, user.reload.email)
  end

  test "password should be present" do
    user.password = user.password_confirmation = " " * 6
    assert_not user.valid?
  end

  test "password should have a minimum length" do
    user.password = user.password_confirmation = "a" * 5
    assert_not user.valid?
  end

  test "authenticated? should return false for user w/ nil digest" do
    assert_not user.authenticated?(:remember, "")
  end

  test "associated microposts should be destroyed if account canceled" do
    user.save
      user.microposts.create!(content: "test")
    assert_difference "Micropost.count", -1 do
      user.destroy
    end
  end

  test "should be able to follow and unfollow other users" do
    user_one = users(:user_one)
    user_two = users(:user_two)
    assert_not user_one.following?(user_two)
    user_one.follow(user_two)
    assert user_two.followers.include?(user_one)
    assert user_one.following?(user_two)
  end

  test "feed should display followed & own posts only" do
    user_zero = users(:user_zero)
    user_one  = users(:user_one)
    user_two  = users(:user_two)
    # posts from followed user
    user_zero.microposts.each do |post|
      assert user_one.feed.include?(post)
    end
    # posts from self
    user_one.microposts.each do |post|
      assert user_one.feed.include?(post)
    end
    # posts from unfollowed user
    user_two.microposts.each do |post|
      assert_not user_one.feed.include?(post)
    end
  end

  private
    attr_reader :user
end
