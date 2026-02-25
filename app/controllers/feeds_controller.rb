class FeedsController < ApplicationController
  def index
    feeds = Feed.active.includes(:tags).order(:name)

    if params[:tag].present?
      @current_tag = Tag.find_by(slug: params[:tag])
      feeds = feeds.joins(:tags).where(tags: { slug: params[:tag] }) if @current_tag
    end

    @feeds_by_category = feeds.group_by(&:category)
    @subscribed_feed_ids = current_user.subscribed_feeds.pluck(:id).to_set
    @tags = Tag.joins(:feed_tags).distinct.order(:name)
  end

  def create
    url = params[:feed_url].to_s.strip
    if url.blank?
      redirect_to feeds_path, alert: "Please enter a feed URL."
      return
    end

    existing = Feed.find_by(url: url)
    if existing
      current_user.subscriptions.find_or_create_by(feed: existing)
      redirect_to feeds_path, notice: "Subscribed to #{existing.name}."
      return
    end

    result = FeedValidator.new.validate(url)
    unless result.valid?
      redirect_to feeds_path, alert: result.error
      return
    end

    feed = Feed.create!(url: url, name: result.name)
    current_user.subscriptions.create!(feed: feed)
    redirect_to feeds_path, notice: "Added and subscribed to #{feed.name}."
  end
end
