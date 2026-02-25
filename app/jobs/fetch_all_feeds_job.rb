class FetchAllFeedsJob < ApplicationJob
  queue_as :default

  def perform
    feeds = Feed.due.order(:last_fetched_at)
    Rails.logger.info("FetchAllFeedsJob: #{feeds.count} feeds due")

    feeds.find_each do |feed|
      FetchFeedJob.perform_later(feed.id)
    end
  end
end
