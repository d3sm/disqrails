class ApplicationController < ActionController::Base
  allow_browser versions: :modern
  stale_when_importmap_changes

  helper_method :giphy_api_key

  private

  def giphy_api_key
    return ENV["GIPHY_API_KEY"] if ENV["GIPHY_API_KEY"].present?

    key_path = Rails.root.join("config/giphy.key")
    return unless key_path.exist?

    key_path.read.strip.presence
  rescue StandardError
    nil
  end
end
