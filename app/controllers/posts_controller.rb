class PostsController < ApplicationController
  PER_PAGE = 20

  def index
    @source_filter = params[:source]
    @tag_filter = params[:tag]
    @sort = Post::SORT_MODES.include?(params[:sort]) ? params[:sort] : "new"

    scope = if @source_filter == "external"
              external_scope
            elsif @source_filter == "feed"
              feed_scope
            else
              all_scope
            end

    scope = apply_tag_filter(scope)
    scope = apply_subscription_filter(scope)
    scope = Post.apply_sort(scope, @sort)

    @current_tag = Tag.find_by(slug: @tag_filter) if @tag_filter.present?
    @tags = Tag.joins(:feeds).distinct.order("tags.name")

    @page = [params.fetch(:page, 1).to_i, 1].max
    paged_posts = scope.includes(:feed, :user).offset((@page - 1) * PER_PAGE).limit(PER_PAGE + 1).to_a
    @next_page = paged_posts.length > PER_PAGE ? @page + 1 : nil
    @posts = paged_posts.first(PER_PAGE)
  end

  def show
    @post = Post.find_by_param!(params[:id])
    @comment_sort = Comment::SORT_MODES.include?(params[:comment_sort]) ? params[:comment_sort] : "threaded"
    all_comments = @post.comments.includes(:comment_reactions, :user).then { |scope| apply_comment_sort(scope) }
    @local_comments = all_comments.select { |c| c.local_reply? || c.external_id.blank? }
    @external_comments = all_comments.select { |c| c.external_id.present? && !c.local_reply? }
    @external_comments_loaded = @external_comments.any?
    @user_reactions = build_user_reactions(all_comments)
    @post_reaction = current_user&.post_reactions&.find_by(post: @post)
  end

  def load_external_comments
    @post = Post.find_by_param!(params[:id])
    import_external_comments!(@post)
    all_comments = @post.comments.includes(:comment_reactions, :user).threaded_order
    @external_comments = all_comments.select { |c| c.external_id.present? && !c.local_reply? }
    @user_reactions = build_user_reactions(all_comments)

    render layout: false
  end

  private

  def build_user_reactions(comments)
    return {} unless current_user

    ids = comments.map(&:id)
    current_user.comment_reactions.where(comment_id: ids).index_by(&:comment_id)
  end

  def feed_scope
    Post.where(source: "feed")
  end

  def external_scope
    ImportHackerNewsJob.perform_later if Post.from_external.none? || params[:refresh] == "1"
    Post.from_external
  end

  def all_scope
    if Post.none?
      FetchAllFeedsJob.perform_later
      ImportHackerNewsJob.perform_later
    elsif params[:refresh] == "1"
      ImportHackerNewsJob.perform_later
    end
    Post.all
  end

  def apply_tag_filter(scope)
    return scope if @tag_filter.blank?

    scope.joins(feed: :tags).where(tags: { slug: @tag_filter })
  end

  def apply_subscription_filter(scope)
    return scope unless current_user&.subscriptions&.any?

    subscribed_feed_ids = current_user.subscribed_feeds.pluck(:id)
    scope.where("posts.source IN (?) OR posts.feed_id IN (?)", Post::EXTERNAL_SOURCES.keys, subscribed_feed_ids)
  end

  def apply_comment_sort(scope)
    case @comment_sort
    when "newest" then scope.order(posted_at: :desc, id: :desc)
    when "oldest" then scope.order(posted_at: :asc, id: :asc)
    else scope.threaded_order
    end
  end

  def import_external_comments!(post)
    return if post.external_id.blank?

    result = HackerNewsCommentsImporter.new.import_for_post(post, max_comments: 120, max_depth: 6, max_seconds: 2.5)
    cache_key = "external:comments:last_imported_at:#{post.id}"
    Rails.cache.write(cache_key, Time.current) unless result[:error]
  rescue StandardError => e
    Rails.logger.warn("External comments import failed for post=#{post.id}: #{e.message}")
  end
end
