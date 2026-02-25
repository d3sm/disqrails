ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

# OmniAuth test mode — no real HTTP calls to GitHub
OmniAuth.config.test_mode = true

module ActiveSupport
  class TestCase
    # System tests + parallel = flaky; keep sequential
    parallelize(workers: 1)

    fixtures :all
  end
end

module SignInHelper
  def sign_in(user)
    identity = user.identities.first!

    OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(
      provider: identity.provider,
      uid: identity.provider_uid,
      info: {
        nickname: identity.provider_handle || user.nickname,
        email: identity.provider_email,
        image: user.avatar_url
      }
    )

    visit "/auth/github/callback"
    assert_text "@#{user.nickname}"
  end
end
