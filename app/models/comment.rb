class Comment < ApplicationRecord
  belongs_to :post
  belongs_to :parent, class_name: "Comment", optional: true
  belongs_to :user, optional: true
  has_many :replies, class_name: "Comment", foreign_key: :parent_id, inverse_of: :parent, dependent: :nullify
  has_many :comment_reactions, dependent: :delete_all

  validates :external_id, presence: true, unless: :local_only?
  validates :external_id, uniqueness: true, allow_nil: true

  scope :threaded_order, -> { order(:position, :id) }

  def display_author
    author.presence || "[deleted]"
  end

  def display_body_html
    return "<p>[deleted]</p>" if external_deleted?
    return "<p>[deleted]</p>" if body_html.blank?

    body_html
  end

  def local_only?
    local_reply
  end

  def external_deleted?
    hn_deleted? || hn_dead?
  end

  def score
    comment_reactions.sum(:value)
  end

  def self.build_local_reply_html(parent:, body:)
    parent_text = ActionController::Base.helpers.strip_tags(parent.display_body_html).squish
    parent_text = parent_text.first(280)
    quoted = parent_text.present? ? "> #{parent_text}" : "> [original message]"
    reply = body.to_s.strip
    source = [quoted, "", reply].join("\n")

    escaped = ERB::Util.html_escape(source)
    ActionController::Base.helpers.simple_format(escaped, {}, sanitize: false)
  end

  def self.build_body_html(body)
    escaped = ERB::Util.html_escape(body.to_s.strip)
    ActionController::Base.helpers.simple_format(escaped, {}, sanitize: false)
  end
end
