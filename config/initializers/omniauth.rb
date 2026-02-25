Rails.application.config.middleware.use OmniAuth::Builder do
  if GithubOauthConfig.ready?
    provider :github, GithubOauthConfig.client_id, GithubOauthConfig.client_secret, scope: "read:user,user:email"
  end
end

OmniAuth.config.allowed_request_methods = [:post]
