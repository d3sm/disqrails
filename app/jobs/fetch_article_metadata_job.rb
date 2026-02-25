class FetchArticleMetadataJob < ApplicationJob
  queue_as :default

  def perform(post_id)
    post = Post.find_by(id: post_id)
    return unless post
    return if post.url.blank?
    return if post.source_image_url.present? && post.source_description.present?

    meta = ArticleMetadataFetcher.new.fetch(post.url)
    return if meta.empty?

    updates = {}
    updates[:source_image_url] = meta[:image_url] if meta[:image_url].present? && post.source_image_url.blank?
    updates[:source_description] = meta[:description] if meta[:description].present? && post.source_description.blank?

    post.update_columns(updates) if updates.any?
  end
end
