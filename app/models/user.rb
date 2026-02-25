class User < ApplicationRecord
  self.primary_key = "id"

  has_many :identities, dependent: :destroy
  has_many :nickname_change_requests, dependent: :destroy
  has_many :comments, dependent: :nullify
  has_many :posts, dependent: :nullify
  has_many :subscriptions, dependent: :delete_all
  has_many :subscribed_feeds, through: :subscriptions, source: :feed
  has_many :post_reactions, dependent: :delete_all
  has_many :comment_reactions, dependent: :delete_all

  validates :nickname, presence: true, uniqueness: { conditions: -> { where(deleted_at: nil) } }
  validates :role, inclusion: { in: %w[user overseer] }

  scope :active, -> { where(deleted_at: nil) }

  def self.from_oauth(auth)
    provider = auth["provider"].to_s
    uid = auth["uid"].to_s
    info = auth["info"] || {}

    identity = Identity.find_by(provider: provider, provider_uid: uid)

    if identity
      user = identity.user
      identity.update!(
        provider_handle: info["nickname"].presence,
        provider_email: info["email"].presence,
        avatar_url: info["image"].presence
      )
      user.update!(avatar_url: info["image"].presence) if info["image"].present?
    else
      handle = info["nickname"].presence || info["name"].presence || "user-#{uid.last(6)}"
      nickname = resolve_unique_nickname(handle)

      user = create!(
        nickname: nickname,
        avatar_url: info["image"].presence
      )
      user.identities.create!(
        provider: provider,
        provider_uid: uid,
        provider_handle: info["nickname"].presence,
        provider_email: info["email"].presence,
        avatar_url: info["image"].presence
      )
    end
    user
  end

  def overseer?
    role == "overseer"
  end

  def deleted?
    deleted_at.present?
  end

  def subscribe_to_featured_feeds!
    return if subscriptions.any?

    Feed.featured.find_each do |feed|
      subscriptions.create(feed: feed)
    end
  end

  def soft_delete!
    raise "Cannot delete the last overseer" if overseer? && User.active.where(role: "overseer").count <= 1

    transaction do
      identities.destroy_all
      subscriptions.delete_all
      post_reactions.delete_all
      comment_reactions.delete_all
      update!(
        deleted_at: Time.current,
        nickname: "[deleted]-#{id.first(8)}",
        avatar_url: nil
      )
    end
  end

  def recompute_karma!
    post_karma = PostReaction.joins(:post).where(posts: { user_id: id }).sum(:value)
    comment_karma = CommentReaction.joins(:comment).where(comments: { user_id: id }).sum(:value)
    update_column(:karma, post_karma + comment_karma)
  end

  def self.resolve_unique_nickname(base)
    candidate = base
    counter = 1
    while exists?(nickname: candidate)
      counter += 1
      candidate = "#{base}#{counter}"
    end
    candidate
  end
end
