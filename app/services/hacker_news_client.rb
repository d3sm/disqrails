require "json"
require "net/http"

class HackerNewsClient
  BASE_URL = "https://hacker-news.firebaseio.com/v0".freeze

  def top_story_ids(limit: 20)
    ids = get_json("/topstories.json")
    Array(ids).first(limit)
  end

  def item(id)
    get_json("/item/#{id}.json")
  end

  private

  def get_json(path)
    uri = URI("#{BASE_URL}#{path}")
    response = Net::HTTP.start(uri.host, uri.port, use_ssl: true, read_timeout: 5, open_timeout: 5) do |http|
      http.get(uri.request_uri)
    end

    raise "HN API request failed: #{response.code}" unless response.is_a?(Net::HTTPSuccess)

    JSON.parse(response.body)
  end
end
