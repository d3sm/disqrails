class ProfilesController < ApplicationController
  skip_before_action :require_login, only: [:show]

  def show
    @profile_user = User.find(params[:id])

    if @profile_user.deleted?
      render :deleted
      return
    end

    @recent_posts = @profile_user.posts.order(created_at: :desc).limit(10)
    @recent_comments = @profile_user.comments
                                    .where(local_reply: true)
                                    .includes(:post)
                                    .order(created_at: :desc)
                                    .limit(10)

    return unless current_user&.id == @profile_user.id

    @liked_posts = Post.joins(:post_reactions)
                       .where(post_reactions: { user_id: current_user.id, value: 1 })
                       .order("post_reactions.created_at DESC")
                       .limit(20)
    @disliked_posts = Post.joins(:post_reactions)
                          .where(post_reactions: { user_id: current_user.id, value: -1 })
                          .order("post_reactions.created_at DESC")
                          .limit(20)
  end

  def destroy
    unless current_user.id == params[:id]
      redirect_to root_path, alert: "Not authorized."
      return
    end

    if params[:confirm_nickname] != current_user.nickname
      redirect_to user_profile_path(current_user), alert: "Type your nickname to confirm deletion."
      return
    end

    current_user.soft_delete!
    reset_session
    redirect_to login_path, notice: "Your account has been deleted."
  rescue StandardError => e
    redirect_to user_profile_path(current_user), alert: e.message
  end
end
