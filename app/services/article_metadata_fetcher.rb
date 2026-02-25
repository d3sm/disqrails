require "cgi"
require "net/http"
require "uri"

class ArticleMetadataFetcher
  MAX_REDIRECTS = 3

  def fetch(url)
    uri = parse_http_uri(url)
    return {} unless uri

    html, final_uri = fetch_html(uri)
    return {} if html.blank?

    meta = extract_meta(html)
    {
      image_url: normalize_url(meta[:image], final_uri),
      description: normalize_description(meta[:description])
    }.compact
  rescue StandardError
    {}
  end

  private

  def parse_http_uri(url)
    uri = URI.parse(url)
    return unless uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)

    uri
  rescue URI::InvalidURIError
    nil
  end

  def fetch_html(uri, redirects_remaining: MAX_REDIRECTS)
    response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https",
                                                   open_timeout: 3, read_timeout: 4) do |http|
      http.get(uri.request_uri, { "User-Agent" => "disqrails/0.1" })
    end

    if response.is_a?(Net::HTTPRedirection) && redirects_remaining.positive?
      location = response["location"]
      return [nil, uri] if location.blank?

      redirect_uri = URI.join(uri.to_s, location)
      return fetch_html(redirect_uri, redirects_remaining: redirects_remaining - 1)
    end

    return [nil, uri] unless response.is_a?(Net::HTTPSuccess)

    [response.body.to_s, uri]
  end

  def extract_meta(html)
    meta = { image: nil, description: nil }

    html.scan(/<meta\b[^>]*>/i).each do |tag|
      attrs = extract_attributes(tag)
      next if attrs.empty?

      key = (attrs["property"] || attrs["name"]).to_s.downcase
      content = attrs["content"].to_s.strip
      next if key.blank? || content.blank?

      meta[:image] ||= content if %w[og:image twitter:image].include?(key)
      meta[:description] ||= content if %w[og:description twitter:description description].include?(key)
    end

    meta
  end

  def extract_attributes(tag)
    attrs = {}
    tag.scan(/([a-zA-Z:_-]+)\s*=\s*["']([^"']*)["']/) do |name, value|
      attrs[name.downcase] = value
    end
    attrs
  end

  def normalize_url(url, base_uri)
    return if url.blank?

    URI.join(base_uri.to_s, url).to_s
  rescue URI::InvalidURIError
    nil
  end

  def normalize_description(description)
    return if description.blank?

    CGI.unescapeHTML(description).squish
  end
end
