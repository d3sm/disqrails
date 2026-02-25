require "application_system_test_case"

class FeedsTest < ApplicationSystemTestCase
  setup do
    @alice = users(:alice)
    @feed = feeds(:test_blog)
    sign_in @alice
  end

  test "visit feeds page shows feed list" do
    visit feeds_path

    assert_text "Feeds"
    assert_text "Subscribe to feeds to customize your frontpage"
    assert_text "Test Blog"
  end

  test "subscribe to a feed" do
    visit feeds_path

    # Feed should have an empty subscribe button (not checked)
    within "#feed_#{@feed.id}" do
      # Click the subscribe (empty checkbox) button
      find("button").click
    end

    # After subscribing, the button should show a checkmark
    within "#feed_#{@feed.id}" do
      assert_text "✓"
    end
  end

  test "unsubscribe from a feed" do
    # First subscribe
    @alice.subscriptions.create!(feed: @feed)

    visit feeds_path

    within "#feed_#{@feed.id}" do
      assert_text "✓"
      find("button").click
    end

    # After unsubscribing, checkmark should be gone
    within "#feed_#{@feed.id}" do
      assert_no_text "✓"
    end
  end
end
