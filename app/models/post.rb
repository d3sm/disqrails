class Post < ApplicationRecord
  require "uri"

  EXTERNAL_SOURCES = {
    "hacker_news" => { name: "Hacker News", label: "hn", discussion_url: "https://news.ycombinator.com/item?id=%<id>s" }
  }.freeze

  belongs_to :feed, optional: true
  belongs_to :user, optional: true
  has_many :comments, dependent: :delete_all
  has_many :post_reactions, dependent: :delete_all

  validates :title, presence: true
  validate :url_or_text_present

  SORT_MODES = %w[new top source_rank].freeze

  scope :sort_by_new, -> { order(Arel.sql("COALESCE(posts.published_at, posts.created_at) DESC")) }
  scope :sort_by_top, -> { order(Arel.sql("COALESCE(posts.hn_score, 0) DESC, COALESCE(posts.published_at, posts.created_at) DESC")) }
  scope :sort_by_source_rank, lambda {
    order(Arel.sql("COALESCE(posts.hn_rank, 999999) ASC, COALESCE(posts.published_at, posts.created_at) DESC"))
  }
  scope :frontpage_order, -> { sort_by_new }
  scope :from_external, -> { where(source: EXTERNAL_SOURCES.keys) }

  def self.apply_sort(scope, mode)
    case mode
    when "top" then scope.sort_by_top
    when "source_rank" then scope.sort_by_source_rank
    else scope.sort_by_new
    end
  end

  def self.find_by_param!(raw_param)
    param = raw_param.to_s

    if (match = /\Ahn-(\d+)\z/.match(param))
      return find_by!(external_id: match[1].to_i, source: EXTERNAL_SOURCES.keys)
    end

    if (match = /\Ap-(\d+)\z/.match(param))
      return find(match[1].to_i)
    end

    # Backward compatibility for existing numeric links.
    return find(param.to_i) if /\A\d+\z/.match?(param)

    raise ActiveRecord::RecordNotFound, "Couldn't find Post with param=#{param.inspect}"
  end

  def external_source?
    EXTERNAL_SOURCES.key?(source)
  end

  def external_source_name
    EXTERNAL_SOURCES.dig(source, :name) || source.titleize
  end

  def external_source_label
    EXTERNAL_SOURCES.dig(source, :label) || source
  end

  def score
    hn_score || reaction_score
  end

  def reaction_score
    post_reactions.sum(:value)
  end

  def comment_count
    hn_descendants || comments.count
  end

  def author_name
    author.presence || hn_by.presence || "unknown"
  end

  def external_discussion_url
    return if external_id.blank? || !external_source?

    template = EXTERNAL_SOURCES.dig(source, :discussion_url)
    format(template, id: external_id) if template
  end

  def external_rank
    hn_rank
  end

  def to_param
    if external_source? && external_id.present?
      "hn-#{external_id}"
    else
      "p-#{id}"
    end
  end

  def source_domain
    return if url.blank?

    uri = URI.parse(url)
    uri.host&.delete_prefix("www.")
  rescue URI::InvalidURIError
    nil
  end

  def display_description
    source_description.presence || text_summary
  end

  def effective_time
    published_at || created_at
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
