class CommentReaction < ApplicationRecord
  belongs_to :user
  belongs_to :comment

  validates :value, inclusion: { in: [-1, 1] }
  validates :user_id, uniqueness: { scope: :comment_id }
  validate :not_self_reaction

  after_commit :update_author_karma

  private

  def not_self_reaction
    return unless comment&.user_id.present? && user_id == comment.user_id

    errors.add(:base, "Cannot react to your own comment")
  end

  def update_author_karma
    author = comment&.user
    return unless author

    author.recompute_karma!
  end
end
