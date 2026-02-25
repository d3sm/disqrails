class ApplicationController < ActionController::Base
  allow_browser versions: :modern
  stale_when_importmap_changes
  before_action :require_login
  helper_method :current_user, :github_oauth_ready?

  private

  def current_user
    return @current_user if defined?(@current_user)

    @current_user = User.find_by(id: session[:user_id])
  end

  def require_login
    return if current_user.present?
    return if request.path.start_with?("/auth/")
    return if request.path == login_path

    redirect_to login_path, alert: "Sign in with GitHub to continue."
  end

  def github_oauth_ready?
    GithubOauthConfig.ready?
  end

end
