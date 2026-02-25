class FetchFeedJob < ApplicationJob
  queue_as :default

  def perform(feed_id)
    feed = Feed.find_by(id: feed_id)
    return unless feed&.active?

    result = FeedFetcher.new.fetch(feed)
    Rails.logger.info("FetchFeedJob feed=#{feed.id} name=#{feed.name} #{result.inspect}")
  end
end
