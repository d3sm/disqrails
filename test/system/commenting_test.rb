require "application_system_test_case"

class CommentingTest < ApplicationSystemTestCase
  setup do
    @alice = users(:alice)
    @feed_post = posts(:feed_post)
    @comment = comments(:local_comment)
    sign_in @alice
  end

  test "add a top-level comment" do
    visit post_path(@feed_post)

    fill_in "body", with: "This is my test comment"
    click_button "Comment"

    assert_text "Comment added"
    assert_text "This is my test comment"
  end

  test "reply to an existing comment" do
    visit post_path(@feed_post)

    within "#comment-#{@comment.id}" do
      find("summary", text: "Reply").click
      fill_in "body", with: "Nice observation!"
      click_button "Add Reply"
    end

    assert_text "Comment added"
    assert_text "Nice observation!"
  end
end
