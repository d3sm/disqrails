class PostsController < ApplicationController
  PER_PAGE = 20

  def index
    scope = Post.where(source: "hacker_news").frontpage_order
    should_refresh = scope.none? || params[:refresh] == "1"
    if should_refresh
      auto_import_hn!
      scope = Post.where(source: "hacker_news").frontpage_order
    end

    @page = [params.fetch(:page, 1).to_i, 1].max
    @posts = scope.offset((@page - 1) * PER_PAGE).limit(PER_PAGE)
    @next_page = scope.offset(@page * PER_PAGE).exists? ? @page + 1 : nil

    respond_to do |format|
      format.html
      format.json do
        render json: {
          posts: @posts.map { |post| serialized_post(post) },
          next_page: @next_page
        }
      end
    end
  end

  def show
    @post = Post.where(source: "hacker_news").find(params[:id])
    auto_import_hn_comments!(@post) if params[:load_comments] == "1"
    @comments = @post.comments.threaded_order
  end

  private

  def auto_import_hn!
    result = HackerNewsImporter.new.import_top_stories(limit: 30)
    Rails.cache.write("hn:last_imported_at", Time.current) unless result[:error]
  rescue StandardError => e
    Rails.logger.warn("HN auto import failed: #{e.message}")
  end

  def auto_import_hn_comments!(post)
    return if post.external_id.blank?

    cache_key = "hn:comments:last_imported_at:#{post.id}"
    last_imported_at = Rails.cache.read(cache_key)
    needs_import = post.comments.none? && (last_imported_at.nil? || last_imported_at < 30.minutes.ago)
    return unless needs_import

    result = HackerNewsCommentsImporter.new.import_for_post(post, max_comments: 120, max_depth: 6, max_seconds: 2.5)
    Rails.cache.write(cache_key, Time.current) unless result[:error]
  rescue StandardError => e
    Rails.logger.warn("HN comments import failed for post=#{post.id}: #{e.message}")
  end

  def serialized_post(post)
    {
      id: post.id,
      title: post.title,
      path: post_path(post),
      source: post.source,
      url: post.url,
      score: helpers.pluralize(post.score, "point"),
      author: post.author_name,
      comments: helpers.pluralize(post.comment_count, "comment"),
      rank: post.hn_rank,
      created_ago: helpers.time_ago_in_words(post.created_at)
    }
  end
end
