class FeedTag < ApplicationRecord
  belongs_to :feed
  belongs_to :tag
end
