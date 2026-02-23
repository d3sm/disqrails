class Comment < ApplicationRecord
  belongs_to :post

  validates :external_id, presence: true, uniqueness: true

  scope :threaded_order, -> { order(:position, :id) }

  def display_author
    author.presence || "[deleted]"
  end

  def display_body_html
    return "<p>[deleted]</p>" if hn_deleted? || hn_dead?
    return "<p>[deleted]</p>" if body_html.blank?

    body_html
  end
end
