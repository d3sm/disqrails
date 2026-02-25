class PostReaction < ApplicationRecord
  belongs_to :user
  belongs_to :post

  validates :value, inclusion: { in: [-1, 1] }
  validates :user_id, uniqueness: { scope: :post_id }
  validate :not_self_reaction

  after_commit :update_author_karma

  private

  def not_self_reaction
    return unless post&.user_id.present? && user_id == post.user_id

    errors.add(:base, "Cannot react to your own post")
  end

  def update_author_karma
    author = post&.user
    return unless author

    author.recompute_karma!
  end
end
