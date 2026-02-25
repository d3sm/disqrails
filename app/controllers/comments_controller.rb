class CommentsController < ApplicationController
  def create
    post = Post.find_by_param!(params[:post_id])
    body = params[:body].to_s.strip

    if body.blank?
      redirect_to post_path(post), alert: "Comment cannot be empty."
      return
    end

    parent = params[:parent_id].present? ? post.comments.find(params[:parent_id]) : nil

    comment = if parent
                post.comments.new(
                  user: current_user,
                  parent: parent,
                  local_reply: true,
                  parent_external_id: parent.external_id,
                  depth: [parent.depth + 1, 8].min,
                  position: next_local_position(post),
                  author: current_user.nickname,
                  body_html: Comment.build_local_reply_html(parent: parent, body: body),
                  posted_at: Time.current
                )
              else
                post.comments.new(
                  user: current_user,
                  local_reply: true,
                  depth: 0,
                  position: next_local_position(post),
                  author: current_user.nickname,
                  body_html: Comment.build_body_html(body),
                  posted_at: Time.current
                )
              end

    if comment.save
      redirect_to post_path(post, anchor: "comment-#{comment.id}"), notice: "Comment added."
    else
      redirect_to post_path(post), alert: comment.errors.full_messages.to_sentence
    end
  end

  private

  def next_local_position(post)
    current_max = post.comments.maximum(:position) || 0
    current_max + 1
  end
end
