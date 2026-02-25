require "application_system_test_case"

class AuthenticationTest < ApplicationSystemTestCase
  test "unauthenticated user is redirected to login" do
    visit root_path

    assert_text "Sign In"
    assert_current_path login_path
  end

  test "sign in via GitHub OAuth mock" do
    alice = users(:alice)
    sign_in alice

    assert_text "@alice"
    visit root_path
    assert_text "Understanding Ruby GC"
  end

  test "log out redirects to login" do
    alice = users(:alice)
    sign_in alice

    # Open user menu and click Log out
    find("#user-menu-trigger").click
    click_button "Log out"

    assert_text "Sign In"
    assert_text "Signed out"
  end
end
