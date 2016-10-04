require 'test_helper'

class MicropostsInterfaceTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:user_one)
  end

  test "micropost text submit & delete interface" do
    log_in_as(user)
    get root_path
    assert_select "div.pagination"
    # invalid submission
    assert_no_difference "Micropost.count" do
      post microposts_path, params: { micropost: { content: "" } }
    end
    assert_select "div#error_explanation"
    # valid submission
    content = "Test"
    assert_difference "Micropost.count", 1 do
      post microposts_path, params: { micropost: { content: content } }
    end
    assert_redirected_to root_url
    follow_redirect!
    assert_match content, response.body
    # delete post
    assert_select "a", text: "delete"
    first_micropost = @user.microposts.paginate(page: 1).first
    assert_difference "Micropost.count", -1 do
      delete micropost_path(first_micropost)
    end
    # visit different user (no delete links)
    get user_path(users(:user_3))
    assert_select "a", text: "delete", count: 0
  end

  test "micropost home sidebar" do
    # user w/ microposts
    log_in_as(user)
    get root_path
    assert_match "#{ user.microposts.count } microposts", response.body
    # user w/o microposts
    other_user = users(:user_4)
    log_in_as(other_user)
    get root_path
    assert_match "0 microposts", response.body
    # add one micropost to test pluralization
    other_user.microposts.create!(content: "Test")
    get root_path
    assert_match "1 micropost", response.body
  end

  # uncomment to enable image testing
  #test "micropost image uploader" do
    #log_in_as(user)
    #get root_path
    #assert_select "input[type=file]"
    #picture = fixture_file_upload("test/fixtures/kitten.jpg", "image/png")
    #post microposts_path, micropost: { content: "Content", picture: picture }
    #assert user.microposts.first.picture?
  #end

  private
    attr_reader :user
end
