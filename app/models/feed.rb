class Feed < ApplicationRecord
  CATEGORIES = {
    "personal_blog" => "Personal Blogs",
    "company_blog" => "Company Blogs",
    "language_framework" => "Languages & Frameworks",
    "news" => "Tech News"
  }.freeze

  has_many :posts, dependent: :nullify
  has_many :feed_tags, dependent: :delete_all
  has_many :tags, through: :feed_tags
  has_many :subscriptions, dependent: :delete_all
  has_many :subscribers, through: :subscriptions, source: :user

  validates :name, presence: true
  validates :url, presence: true, uniqueness: true

  scope :active, -> { where(active: true) }
  scope :featured, -> { where(featured: true) }
  scope :due, lambda {
    active.where(
      "last_fetched_at IS NULL OR last_fetched_at < NOW() - (fetch_interval_minutes || ' minutes')::interval"
    )
  }

  def record_success!(etag: nil, last_modified: nil)
    update!(
      last_fetched_at: Time.current,
      etag: etag,
      last_modified_header: last_modified,
      error_count: 0,
      last_error: nil
    )
  end

  def record_error!(message)
    increment!(:error_count)
    update_columns(last_error: message.to_s.first(500), last_fetched_at: Time.current)
  end

  def backoff_minutes
    [fetch_interval_minutes * (2**[error_count, 5].min), 1440].min
  end

  def category_label
    CATEGORIES[category] || category.to_s.titleize
  end
end
