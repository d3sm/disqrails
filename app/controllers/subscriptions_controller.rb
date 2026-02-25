class SubscriptionsController < ApplicationController
  def create
    feed = Feed.find(params[:feed_id])
    current_user.subscriptions.find_or_create_by(feed: feed)

    respond_to do |format|
      format.html { redirect_to feeds_path }
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace("feed_#{feed.id}", partial: "feeds/feed_item",
                                                                     locals: { feed: feed, subscribed: true })
      end
    end
  end

  def destroy
    subscription = current_user.subscriptions.find_by(feed_id: params[:id])
    feed = subscription&.feed
    subscription&.destroy

    respond_to do |format|
      format.html { redirect_to feeds_path }
      format.turbo_stream do
        if feed
          render turbo_stream: turbo_stream.replace("feed_#{feed.id}", partial: "feeds/feed_item",
                                                                       locals: { feed: feed, subscribed: false })
        else
          head :ok
        end
      end
    end
  end
end
