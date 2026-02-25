require "application_system_test_case"

class ProfileTest < ApplicationSystemTestCase
  setup do
    @alice = users(:alice)
    sign_in @alice
  end

  test "visit own profile shows nickname and karma" do
    visit user_profile_path(@alice)

    assert_text "@alice"
    assert_text "5 karma"
  end

  test "profile shows recent posts" do
    visit user_profile_path(@alice)

    assert_text "Recent posts"
    assert_text "My First Post on DisqRails"
  end

  test "profile page has delete account section" do
    visit user_profile_path(@alice)

    assert_text "Delete account"
  end

  test "profile is accessible from topbar menu" do
    visit root_path
    find("#user-menu-trigger").click
    click_link "Profile"

    assert_text "@alice"
    assert_text "karma"
  end
end
