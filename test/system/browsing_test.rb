require "application_system_test_case"

class BrowsingTest < ApplicationSystemTestCase
  setup do
    @alice = users(:alice)
    sign_in @alice
  end

  test "visiting root shows post titles" do
    visit root_path

    assert_text "Understanding Ruby GC"
    assert_text "Show HN: A New Database Engine"
    assert_text "My First Post on DisqRails"
  end

  test "clicking a post navigates to detail page" do
    visit root_path
    click_link "Understanding Ruby GC"

    assert_text "Understanding Ruby GC"
    assert_text "Discussion"
    assert_link "Back to posts"
  end

  test "filtering by Blogs source" do
    visit root_path
    click_link "Blogs"

    assert_text "Understanding Ruby GC"
    assert_no_text "Show HN: A New Database Engine"
  end

  test "filtering by Discussions source" do
    visit root_path
    click_link "Discussions"

    assert_text "Show HN: A New Database Engine"
    assert_no_text "Understanding Ruby GC"
  end

  test "filtering by tag" do
    visit root_path
    first(:link, "Ruby").click

    assert_text "Showing posts tagged"
    assert_text "Understanding Ruby GC"
  end

  test "clicking post show then back returns to index" do
    visit root_path
    click_link "Understanding Ruby GC"
    click_link "Back to posts"

    assert_text "Understanding Ruby GC"
    assert_text "Show HN: A New Database Engine"
  end
end
