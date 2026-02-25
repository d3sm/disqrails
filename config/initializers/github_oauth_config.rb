module GithubOauthConfig
  module_function

  def client_id
    ENV["GITHUB_CLIENT_ID"].presence || Rails.application.credentials.dig(:github, :client_id).presence
  end

  def client_secret
    ENV["GITHUB_CLIENT_SECRET"].presence || Rails.application.credentials.dig(:github, :client_secret).presence
  end

  def ready?
    client_id.present? && client_secret.present?
  end
end
