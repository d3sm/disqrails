class NicknameChangeRequest < ApplicationRecord
  belongs_to :user
  belongs_to :reviewer, class_name: "User", foreign_key: :reviewed_by, inverse_of: false, optional: true

  validates :requested_nickname, presence: true
  validates :status, inclusion: { in: %w[pending approved rejected] }

  scope :pending, -> { where(status: "pending") }
end
