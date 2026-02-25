class Tag < ApplicationRecord
  has_many :feed_tags, dependent: :delete_all
  has_many :feeds, through: :feed_tags

  validates :name, presence: true, uniqueness: true # rubocop:disable Rails/UniqueValidationWithoutIndex
  validates :slug, presence: true, uniqueness: true

  before_validation :generate_slug

  private

  def generate_slug
    self.slug = name.to_s.parameterize if slug.blank? && name.present?
  end
end
