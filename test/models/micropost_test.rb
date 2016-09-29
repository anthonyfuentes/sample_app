
require 'test_helper'

class MicropostTest < ActiveSupport::TestCase

  def setup
    @user = users(:user_one)
    @micropost = user.microposts.build(content: "foo")
  end

  test "should be valid do" do
    assert micropost.valid?
  end

  test "user id should be present" do
    micropost.user_id = nil
    assert_not micropost.valid?
  end

  test "content should be present" do
    micropost.content = "    "
    assert_not micropost.valid?
  end

  test "content should be 140 characters or less" do
    micropost.content = "!" * 140
    assert micropost.valid?
    micropost.content = "!" * 141
    assert_not micropost.valid?
  end

  test "most recent microposts should appear first" do
    assert_equal microposts(:most_recent), Micropost.first
  end

  private
    attr_reader :micropost, :user
end
