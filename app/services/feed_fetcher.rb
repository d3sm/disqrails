require "net/http"
require "uri"
require "cgi"

class FeedFetcher
  MAX_REDIRECTS = 3

  def fetch(feed)
    xml, headers = fetch_xml(feed)
    return { imported: 0, skipped: 0, not_modified: true } if xml.nil?

    parsed = Feedjira.parse(xml)
    imported = 0
    skipped = 0

    parsed.entries.each do |entry|
      post = create_post_from(entry, feed)
      if post
        imported += 1
      else
        skipped += 1
      end
    rescue StandardError => e
      Rails.logger.warn("Feed entry import failed: #{e.message}")
      skipped += 1
    end

    feed.record_success!(etag: headers[:etag], last_modified: headers[:last_modified])
    { imported: imported, skipped: skipped }
  rescue Feedjira::NoParserAvailable => e
    feed.record_error!("Parse error: #{e.message}")
    { imported: 0, skipped: 0, error: e.message }
  rescue StandardError => e
    feed.record_error!(e.message)
    { imported: 0, skipped: 0, error: e.message }
  end

  private

  def create_post_from(entry, feed)
    entry_url = entry.url.to_s.strip
    return nil if entry_url.blank?

    entry_url = normalize_url(entry_url)
    return nil if Post.exists?(url: entry_url)

    title = clean_text(entry.title)
    return nil if title.blank?

    post = Post.new(
      feed: feed, source: "feed", title: title, url: entry_url,
      author: clean_text(entry_author(entry, feed)),
      text: entry_summary(entry),
      published_at: entry.published || entry.updated,
      source_description: clean_text(entry_description(entry))
    )

    post.save!
  end

  def fetch_xml(feed, redirects: MAX_REDIRECTS)
    uri = URI.parse(feed.url)
    headers = { "User-Agent" => "disqrails/0.1" }
    headers["If-None-Match"] = feed.etag if feed.etag.present?
    headers["If-Modified-Since"] = feed.last_modified_header if feed.last_modified_header.present?

    response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https",
                                                   open_timeout: 10, read_timeout: 15) do |http|
      http.get(uri.request_uri, headers)
    end

    case response
    when Net::HTTPNotModified
      nil
    when Net::HTTPRedirection
      return nil if redirects <= 0

      redirect_uri = URI.join(uri.to_s, response["location"])
      original_url = feed.url
      feed.url = redirect_uri.to_s
      fetch_xml(feed, redirects: redirects - 1).tap do
        feed.url = original_url if feed.url != redirect_uri.to_s
      end
    when Net::HTTPSuccess
      [response.body, { etag: response["etag"], last_modified: response["last-modified"] }]
    else
      raise "HTTP #{response.code} from #{feed.url}"
    end
  end

  def entry_author(entry, feed)
    entry.author.presence || feed.name
  end

  def entry_summary(entry)
    content = entry.content.presence || entry.summary.presence
    return if content.blank?

    content.to_s.first(10_000)
  end

  def entry_description(entry)
    text = entry.summary.presence || entry.content.presence
    return if text.blank?

    text.gsub(/<[^>]*>/, " ").squish.truncate(300)
  end

  def clean_text(value)
    return if value.blank?

    CGI.unescapeHTML(value.to_s).strip
  end

  def normalize_url(url)
    uri = URI.parse(url)
    uri.fragment = nil
    uri.query = clean_query(uri.query) if uri.query
    uri.to_s
  rescue URI::InvalidURIError
    url
  end

  def clean_query(query)
    return nil if query.blank?

    cleaned = query.split("&").reject { |p| p.start_with?("utm_") }.join("&")
    cleaned.presence
  end

end
