class ReactionsController < ApplicationController
  before_action :set_reactable

  def create
    value = params[:value].to_i

    unless [1, -1].include?(value)
      redirect_back_or_to(post_path(target_post), alert: "Invalid reaction.")
      return
    end

    scope = current_user.public_send(reaction_scope)
    existing = scope.find_by(@reactable_key => @reactable)

    if existing
      existing.destroy!
    else
      scope.create!(@reactable_key => @reactable, value: value)
    end

    redirect_back_or_to(redirect_target)
  end

  private

  def set_reactable
    if params[:comment_id].present?
      @reactable = Comment.find(params[:comment_id])
      @reactable_key = :comment
    else
      @reactable = Post.find_by_param!(params[:post_id])
      @reactable_key = :post
    end
  end

  def reaction_scope
    @reactable_key == :post ? :post_reactions : :comment_reactions
  end

  def target_post
    @reactable_key == :post ? @reactable : @reactable.post
  end

  def redirect_target
    if @reactable_key == :post
      post_path(@reactable)
    else
      post_path(@reactable.post, anchor: "comment-#{@reactable.id}")
    end
  end
end
