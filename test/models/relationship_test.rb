
require 'test_helper'

class RelationshipTest < ActiveSupport::TestCase

  def setup
    @relationship = Relationship.new(follower_id: users(:user_one).id,
                                     followed_id: users(:user_two).id)
  end

  test "should be valid" do
    assert relationship.valid?
  end

  test "should require a follower_id" do
    relationship.follower_id = nil
    assert_not relationship.valid?
  end

  test "should require a followed_id" do
    relationship.followed_id = nil
    assert_not relationship.valid?
  end

  private
    attr_reader :relationship
end
