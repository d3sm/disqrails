class ImportHackerNewsJob < ApplicationJob
  queue_as :default

  def perform
    result = HackerNewsImporter.new.import_top_stories(limit: 30)
    Rails.cache.write("external:last_imported_at", Time.current) unless result[:error]
    Rails.logger.info("ImportHackerNewsJob: #{result.inspect}")
  end
end
