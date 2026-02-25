class FeedValidator
  TIMEOUT = 10

  Result = Struct.new(:valid, :name, :entry_count, :error, keyword_init: true) do
    def valid? = valid
  end

  def validate(url)
    uri = URI.parse(url)
    unless uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)
      return Result.new(valid: false, error: "URL must start with http:// or https://")
    end

    response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https", open_timeout: TIMEOUT,
                                                   read_timeout: TIMEOUT) do |http|
      http.get(uri.request_uri, "User-Agent" => "HackerOnRails/1.0")
    end

    unless response.is_a?(Net::HTTPSuccess)
      return Result.new(valid: false, error: "HTTP #{response.code}: could not fetch feed")
    end

    feed = Feedjira.parse(response.body)
    Result.new(valid: true, name: feed.title.presence || uri.host, entry_count: feed.entries.size)
  rescue URI::InvalidURIError
    Result.new(valid: false, error: "Invalid URL format")
  rescue Feedjira::NoParserAvailable
    Result.new(valid: false, error: "Not a valid RSS or Atom feed")
  rescue Net::OpenTimeout, Net::ReadTimeout
    Result.new(valid: false, error: "Feed URL timed out")
  rescue StandardError => e
    Result.new(valid: false, error: "Could not fetch feed: #{e.message}")
  end
end
