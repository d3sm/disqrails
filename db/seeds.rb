# Import base feeds from OPML
opml_path = Rails.root.join("config/feeds.opml")
if opml_path.exist?
  result = OpmlImporter.new.import_file(opml_path)
  puts "OPML import: #{result.inspect}"
end

# Seed tags on base feeds
Rake::Task["feeds:seed_tags"].invoke

# Add expanded feed set
Rake::Task["feeds:expand"].invoke

puts "Seeds done. #{Feed.count} feeds, #{Tag.count} tags."
puts "Content will be fetched by recurring jobs (FetchAllFeedsJob, ImportHackerNewsJob)."
