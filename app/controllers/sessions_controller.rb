class SessionsController < ApplicationController
  skip_before_action :require_login, only: [:new, :create, :failure]

  def new; end

  def create
    auth = request.env["omniauth.auth"]
    if auth.blank?
      redirect_to login_path, alert: "GitHub authentication failed."
      return
    end

    user = User.from_oauth(auth)
    reset_session
    session[:user_id] = user.id
    user.subscribe_to_featured_feeds!

    redirect_to posts_path, notice: "Signed in as @#{user.nickname}."
  rescue StandardError => e
    Rails.logger.warn("GitHub auth failed: #{e.message}")
    redirect_to login_path, alert: "Could not complete GitHub sign in."
  end

  def destroy
    reset_session
    redirect_to login_path, notice: "Signed out."
  end

  def failure
    redirect_to login_path, alert: "Authentication canceled or failed."
  end
end
