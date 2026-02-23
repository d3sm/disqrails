require "cgi"

class HackerNewsImporter
  def initialize(client: HackerNewsClient.new, metadata_fetcher: ArticleMetadataFetcher.new)
    @client = client
    @metadata_fetcher = metadata_fetcher
  end

  def import_top_stories(limit: 20)
    imported = 0
    skipped = 0

    client.top_story_ids(limit: limit).each_with_index do |story_id, index|
      story = client.item(story_id)

      unless importable_story?(story)
        skipped += 1
        next
      end

      post = Post.find_or_initialize_by(external_id: story["id"])
      post.source = "hacker_news"
      post.hn_rank = index + 1
      post.hn_score = story["score"]
      post.hn_descendants = story["descendants"]
      post.hn_by = story["by"]
      post.hn_type = story["type"]
      post.title = CGI.unescapeHTML(story["title"].to_s.strip)
      post.url = story["url"]
      post.text = story["text"]
      apply_article_metadata!(post)
      post.created_at = Time.at(story["time"]) if post.new_record? && story["time"].present?

      if post.title.blank? || (post.url.blank? && post.text.blank?)
        skipped += 1
        next
      end

      post.save!
      imported += 1
    end

    { imported: imported, skipped: skipped }
  rescue StandardError => e
    { imported: imported, skipped: skipped, error: e.message }
  end

  private

  attr_reader :client, :metadata_fetcher

  def importable_story?(story)
    return false unless story.is_a?(Hash) && story["id"].present?

    story["type"] == "story"
  end

  def apply_article_metadata!(post)
    return if post.url.blank?
    return if post.source_image_url.present? && post.source_description.present?

    metadata = metadata_fetcher.fetch(post.url)
    return if metadata.blank?

    post.source_image_url = metadata[:image_url] if metadata[:image_url].present?
    post.source_description = metadata[:description] if metadata[:description].present?
  end
end
