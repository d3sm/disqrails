class Post < ApplicationRecord
  require "uri"

  has_many :comments, dependent: :delete_all

  validates :title, presence: true
  validate :url_or_text_present

  scope :frontpage_order, -> {
    order(
      Arel.sql(
        <<~SQL.squish
          CASE WHEN source = 'hacker_news' THEN 0 ELSE 1 END ASC,
          hn_rank ASC NULLS LAST,
          created_at DESC
        SQL
      )
    )
  }

  def score
    hn_score || 0
  end

  def comment_count
    hn_descendants || 0
  end

  def author_name
    hn_by.presence || "unknown"
  end

  def hn_discussion_url
    return if external_id.blank?

    "https://news.ycombinator.com/item?id=#{external_id}"
  end

  def source_domain
    return if url.blank?

    uri = URI.parse(url)
    uri.host&.sub(/\Awww\./, "")
  rescue URI::InvalidURIError
    nil
  end

  def display_description
    source_description.presence || text_summary
  end

  private

  def url_or_text_present
    return if url.present? || text.present?

    errors.add(:base, "Provide a URL or text")
  end

  def text_summary
    return if text.blank?

    text.gsub(/<[^>]*>/, " ").squish.truncate(280)
  end
end
