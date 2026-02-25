namespace :storage do
  desc "Print DB size metrics"
  task metrics: :environment do
    puts "Posts:            #{Post.count}"
    puts "Comments:         #{Comment.count}"
    puts "Users:            #{User.count}"
    puts "Feeds:            #{Feed.count}"
    puts "PostReactions:    #{PostReaction.count}"
    puts "CommentReactions: #{CommentReaction.count}"
    puts "Identities:       #{Identity.count}"

    sizes = ActiveRecord::Base.connection.execute(<<~SQL.squish)
      SELECT relname AS table,
             pg_size_pretty(pg_total_relation_size(relid)) AS total_size
      FROM pg_catalog.pg_statio_user_tables
      ORDER BY pg_total_relation_size(relid) DESC
    SQL

    puts "\nTable sizes:"
    sizes.each { |row| puts format("  %-30<table>s %<size>s", table: row["table"], size: row["total_size"]) }

    db_size = ActiveRecord::Base.connection.execute(
      "SELECT pg_size_pretty(pg_database_size(current_database())) AS size"
    ).first["size"]
    puts "\nTotal DB size: #{db_size}"
  end

  desc "Run prune job (dry run by default, pass CONFIRM=1 to execute)"
  task prune: :environment do
    if ENV["CONFIRM"] == "1"
      PruneStaleDataJob.perform_now
      puts "Prune complete."
    else
      puts "Dry run — showing what would be pruned:"
      puts "  Imported comments older than 7 days: #{Comment.where.not(external_id: nil).where(local_reply: false).where(created_at: ...7.days.ago).count}"
      puts "  Posts with heavy payload older than 14 days: #{Post.where.not(source: 'local').where(user_id: nil).where(created_at: ...14.days.ago).where('text IS NOT NULL OR source_description IS NOT NULL OR source_image_url IS NOT NULL').count}"

      Post::EXTERNAL_SOURCES.each_key do |source|
        cap = PruneStaleDataJob::SOURCE_CAPS[source] || "no cap"
        puts "  #{source} posts: #{Post.where(source: source).count} (cap: #{cap})"
      end

      Feed.where("(SELECT COUNT(*) FROM posts WHERE posts.feed_id = feeds.id) > ?",
                 PruneStaleDataJob::PER_FEED_CAP).find_each do |feed|
        puts "  Feed '#{feed.name}': #{feed.posts.count} posts (cap: #{PruneStaleDataJob::PER_FEED_CAP})"
      end

      puts "\nRun with CONFIRM=1 to execute."
    end
  end
end
