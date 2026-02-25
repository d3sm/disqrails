class HackerNewsCommentsImporter
  DEFAULT_MAX_COMMENTS = 120
  DEFAULT_MAX_DEPTH = 6
  DEFAULT_MAX_SECONDS = 2.5

  def initialize(client: HackerNewsClient.new)
    @client = client
  end

  def import_for_post(post, max_comments: DEFAULT_MAX_COMMENTS, max_depth: DEFAULT_MAX_DEPTH,
                      max_seconds: DEFAULT_MAX_SECONDS)
    return { imported: 0, skipped: 0 } if post.external_id.blank?

    story = client.item(post.external_id)
    comment_ids = Array(story["kids"])
    return { imported: 0, skipped: 0 } if comment_ids.empty?

    flattened = []
    seen_ids = Set.new
    deadline = Process.clock_gettime(Process::CLOCK_MONOTONIC) + max_seconds
    traverse(
      comment_ids,
      depth: 0,
      parent_external_id: nil,
      out: flattened,
      seen_ids: seen_ids,
      max_comments: max_comments,
      max_depth: max_depth,
      deadline: deadline
    )

    Comment.transaction do
      post.comments.delete_all
      now = Time.current
      rows = flattened.each_with_index.map do |attrs, index|
        attrs.merge(post_id: post.id, position: index + 1, created_at: now, updated_at: now)
      end
      Comment.insert_all(rows) if rows.any?
    end

    timed_out = Process.clock_gettime(Process::CLOCK_MONOTONIC) >= deadline
    { imported: flattened.size, skipped: 0, timed_out: timed_out }
  rescue StandardError => e
    { imported: 0, skipped: 0, error: e.message }
  end

  private

  attr_reader :client

  def traverse(ids, depth:, parent_external_id:, out:, seen_ids:, max_comments:, max_depth:, deadline:)
    return if Process.clock_gettime(Process::CLOCK_MONOTONIC) >= deadline
    return if depth > max_depth
    return if out.size >= max_comments

    ids.each do |id|
      break if Process.clock_gettime(Process::CLOCK_MONOTONIC) >= deadline
      break if out.size >= max_comments

      item = client.item(id)
      next unless item.is_a?(Hash) && item["id"].present?
      next unless item["type"] == "comment"
      next if seen_ids.include?(item["id"])

      seen_ids << item["id"]
      out << {
        external_id: item["id"],
        parent_external_id: parent_external_id,
        depth: depth,
        author: item["by"],
        body_html: item["text"],
        posted_at: item["time"].present? ? Time.zone.at(item["time"]) : nil,
        hn_deleted: item["deleted"] == true,
        hn_dead: item["dead"] == true
      }

      traverse(
        Array(item["kids"]),
        depth: depth + 1,
        parent_external_id: item["id"],
        out: out,
        seen_ids: seen_ids,
        max_comments: max_comments,
        max_depth: max_depth,
        deadline: deadline
      )
    end
  end
end
