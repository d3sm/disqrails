class PruneStaleDataJob < ApplicationJob
  IMPORTED_COMMENTS_TTL = 7.days
  HEAVY_PAYLOAD_TTL = 14.days
  SOURCE_CAPS = {
    "hacker_news" => 500
  }.freeze
  PER_FEED_CAP = 200

  def perform
    prune_imported_comments!
    prune_heavy_payloads!
    enforce_source_caps!
    enforce_feed_caps!
  end

  private

  def prune_imported_comments!
    # Keep external comments that have local replies as children
    parent_ids_with_local_replies = Comment.where(local_reply: true)
                                           .where.not(parent_id: nil).distinct.pluck(:parent_id)

    deleted = Comment
              .where.not(external_id: nil)
              .where(local_reply: false)
              .where(created_at: ...IMPORTED_COMMENTS_TTL.ago)
              .where.not(id: parent_ids_with_local_replies)
              .delete_all

    Rails.logger.info("PruneStaleDataJob: deleted #{deleted} imported comments")
  end

  def prune_heavy_payloads!
    updated = Post
              .where.not(source: "local")
              .where(user_id: nil)
              .where(created_at: ...HEAVY_PAYLOAD_TTL.ago)
              .where("text IS NOT NULL OR source_description IS NOT NULL OR source_image_url IS NOT NULL")
              .update_all(
                text: nil,
                source_description: nil,
                source_image_url: nil,
                hn_score: nil,
                hn_descendants: nil,
                hn_rank: nil
              )

    Rails.logger.info("PruneStaleDataJob: pruned heavy payload from #{updated} posts")
  end

  def enforce_source_caps!
    SOURCE_CAPS.each do |source, cap|
      count = Post.where(source: source).count
      next if count <= cap

      cutoff_id = Post.where(source: source).order(created_at: :desc).offset(cap).limit(1).pick(:id)
      next unless cutoff_id

      stale = Post.where(source: source).where(id: ..cutoff_id)
      purge_posts!(stale)
      Rails.logger.info("PruneStaleDataJob: capped #{source} (was #{count}, cap #{cap})")
    end
  end

  def enforce_feed_caps!
    Feed.find_each do |feed|
      count = feed.posts.count
      next if count <= PER_FEED_CAP

      cutoff_id = feed.posts.order(created_at: :desc).offset(PER_FEED_CAP).limit(1).pick(:id)
      next unless cutoff_id

      stale = feed.posts.where(id: ..cutoff_id)
      purge_posts!(stale)
      Rails.logger.info("PruneStaleDataJob: capped feed #{feed.name}")
    end
  end

  def purge_posts!(scope)
    ids = scope.pluck(:id)
    return if ids.empty?

    CommentReaction.where(comment_id: Comment.where(post_id: ids).select(:id)).delete_all
    Comment.where(post_id: ids).delete_all
    PostReaction.where(post_id: ids).delete_all
    Post.where(id: ids).delete_all
  end
end
