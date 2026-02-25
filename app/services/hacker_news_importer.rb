require "cgi"

class HackerNewsImporter
  def initialize(client: HackerNewsClient.new)
    @client = client
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
      post.author = story["by"]
      post.published_at ||= Time.zone.at(story["time"]) if story["time"].present?
      post.created_at = Time.zone.at(story["time"]) if post.new_record? && story["time"].present?

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

  attr_reader :client

  def importable_story?(story)
    return false unless story.is_a?(Hash) && story["id"].present?

    story["type"] == "story"
  end
end
