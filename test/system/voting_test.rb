require "application_system_test_case"

class VotingTest < ApplicationSystemTestCase
  setup do
    @alice = users(:alice)
    @feed_post = posts(:feed_post)
    @comment = comments(:local_comment)
    sign_in @alice
  end

  test "upvote a post" do
    visit post_path(@feed_post)

    assert_selector "form[action='#{post_reaction_path(@feed_post)}?value=1'] button[title='Upvote']"
    find("form[action='#{post_reaction_path(@feed_post)}?value=1'] button[title='Upvote']").click
    assert_selector "form[action='#{post_reaction_path(@feed_post)}?value=1'] + span", text: "1"
  end

  test "downvote a post" do
    visit post_path(@feed_post)

    assert_selector "form[action='#{post_reaction_path(@feed_post)}?value=-1'] button[title='Downvote']"
    find("form[action='#{post_reaction_path(@feed_post)}?value=-1'] button[title='Downvote']").click
    assert_selector "form[action='#{post_reaction_path(@feed_post)}?value=1'] + span", text: "-1"
  end

  test "toggle off an upvote" do
    visit post_path(@feed_post)

    find("form[action='#{post_reaction_path(@feed_post)}?value=1'] button[title='Upvote']").click
    assert_selector "form[action='#{post_reaction_path(@feed_post)}?value=1'] + span", text: "1"

    visit post_path(@feed_post)

    find("form[action='#{post_reaction_path(@feed_post)}?value=1'] button[title='Upvote']").click
    assert_selector "form[action='#{post_reaction_path(@feed_post)}?value=1'] + span", text: "0"
  end

  test "upvote a comment" do
    visit post_path(@feed_post)

    within "#comment-#{@comment.id}" do
      assert_text "0"
      click_button "Upvote"
    end

    within "#comment-#{@comment.id}" do
      assert_text "1"
    end
  end
end
