namespace :feeds do
  desc "Import feeds from an OPML file: rake feeds:import_opml[path/to/file.opml]"
  task :import_opml, [:path] => :environment do |_t, args|
    path = args[:path]
    abort "Usage: rake feeds:import_opml[path/to/file.opml]" if path.blank?
    abort "File not found: #{path}" unless File.exist?(path)

    result = OpmlImporter.new.import_file(path)
    puts "Imported #{result[:imported]} feeds, skipped #{result[:skipped]}"
    puts "Total active feeds: #{Feed.active.count}"
  end

  desc "Fetch all due feeds now (inline, no background jobs)"
  task fetch: :environment do
    feeds = Feed.due.order(:last_fetched_at)
    puts "#{feeds.count} feeds due for fetching"

    fetcher = FeedFetcher.new
    feeds.find_each do |feed|
      print "  #{feed.name}... "
      result = fetcher.fetch(feed)
      if result[:error]
        puts "ERROR: #{result[:error]}"
      elsif result[:not_modified]
        puts "not modified"
      else
        puts "#{result[:imported]} new, #{result[:skipped]} skipped"
      end
    end

    puts "Done. Total posts: #{Post.count}"
  end

  desc "Enqueue background jobs for all due feeds"
  task enqueue: :environment do
    FetchAllFeedsJob.perform_later
    puts "Enqueued FetchAllFeedsJob"
  end

  desc "Seed tags and categories on existing feeds"
  task seed_tags: :environment do
    feed_data = {
      "Julia Evans" => { category: "personal_blog", tags: %w[linux networking debugging], featured: true },
      "Dan Luu" => { category: "personal_blog", tags: %w[performance systems], featured: true },
      "Simon Willison" => { category: "personal_blog", tags: %w[python ai databases], featured: true },
      "Fly.io" => { category: "company_blog", tags: %w[infrastructure go distributed-systems], featured: true },
      "Cloudflare" => { category: "company_blog", tags: %w[infrastructure networking security], featured: true },
      "Dan Abramov" => { category: "personal_blog", tags: %w[frontend react javascript], featured: true },
      "Tailscale" => { category: "company_blog", tags: %w[networking security go], featured: true },
      "Drew DeVault" => { category: "personal_blog", tags: %w[linux open-source], featured: true },
      "Rachel Kroll" => { category: "personal_blog", tags: %w[systems debugging], featured: true },
      "Evil Martians" => { category: "company_blog", tags: %w[ruby rails frontend], featured: true },
      "Netflix TechBlog" => { category: "company_blog", tags: %w[infrastructure distributed-systems java],
                              featured: false },
      "Stripe" => { category: "company_blog", tags: %w[infrastructure ruby api], featured: false }
    }

    feed_data.each do |name, data|
      feed = Feed.find_by(name: name)
      next unless feed

      feed.update!(category: data[:category], featured: data[:featured])

      data[:tags].each do |tag_name|
        tag = Tag.find_or_create_by!(name: tag_name) { |t| t.slug = tag_name.parameterize }
        FeedTag.find_or_create_by!(feed: feed, tag: tag)
      end

      puts "  #{name}: #{data[:category]}, tags: #{data[:tags].join(', ')}, featured: #{data[:featured]}"
    end

    puts "\nDone. #{Tag.count} tags, #{FeedTag.count} feed-tag associations."
  end

  desc "Add expanded set of feeds with categories and tags"
  task expand: :environment do
    new_feeds = [
      # === Company Blogs (top picks from engblogs) ===
      { name: "GitHub Engineering", url: "https://githubengineering.com/atom.xml",
        site_url: "https://github.blog/engineering/", category: "company_blog", tags: %w[infrastructure git open-source], featured: true },
      { name: "Dropbox Engineering", url: "https://dropbox.tech/feed", site_url: "https://dropbox.tech/",
        category: "company_blog", tags: %w[infrastructure python], featured: false },
      { name: "Spotify Engineering", url: "https://labs.spotify.com/feed/",
        site_url: "https://engineering.atspotify.com/", category: "company_blog", tags: %w[infrastructure data], featured: false },
      { name: "Uber Engineering", url: "https://eng.uber.com/feed/", site_url: "https://eng.uber.com/",
        category: "company_blog", tags: %w[infrastructure distributed-systems], featured: false },
      { name: "Slack Engineering", url: "https://slack.engineering/feed", site_url: "https://slack.engineering/",
        category: "company_blog", tags: %w[infrastructure frontend], featured: false },
      { name: "Discord Engineering", url: "https://blog.discordapp.com/feed",
        site_url: "https://discord.com/category/engineering", category: "company_blog", tags: %w[infrastructure rust], featured: false },
      { name: "Vercel", url: "https://vercel.com/atom", site_url: "https://vercel.com/blog", category: "company_blog",
        tags: %w[frontend javascript infrastructure], featured: false },
      { name: "HashiCorp", url: "https://www.hashicorp.com/blog/feed.xml", site_url: "https://www.hashicorp.com/blog/",
        category: "company_blog", tags: %w[infrastructure go devops], featured: false },
      { name: "AWS Blog", url: "https://aws.amazon.com/blogs/aws/feed/", site_url: "https://aws.amazon.com/blogs/aws/",
        category: "company_blog", tags: %w[infrastructure cloud], featured: false },
      { name: "Stack Overflow Blog", url: "https://stackoverflow.blog/feed/", site_url: "https://stackoverflow.blog/",
        category: "company_blog", tags: %w[engineering community], featured: false },
      { name: "Confluent", url: "https://www.confluent.io/feed/", site_url: "https://www.confluent.io/blog",
        category: "company_blog", tags: %w[distributed-systems data], featured: false },
      { name: "Databricks", url: "https://databricks.com/feed", site_url: "https://databricks.com/blog",
        category: "company_blog", tags: %w[data ai], featured: false },
      { name: "Airbnb Engineering", url: "https://medium.com/feed/airbnb-engineering",
        site_url: "https://medium.com/airbnb-engineering", category: "company_blog", tags: %w[frontend infrastructure], featured: false },
      { name: "Etsy Engineering", url: "https://codeascraft.com/feed/", site_url: "https://codeascraft.com/",
        category: "company_blog", tags: %w[infrastructure performance], featured: false },
      { name: "Jane Street Tech", url: "https://blogs.janestreet.com/feed.xml",
        site_url: "https://blog.janestreet.com/", category: "company_blog", tags: %w[ocaml functional-programming], featured: true },
      { name: "DigitalOcean", url: "https://blog.digitalocean.com/rss/", site_url: "https://blog.digitalocean.com/",
        category: "company_blog", tags: %w[infrastructure cloud], featured: false },

      # === Personal Blogs (notable engineers) ===
      { name: "Martin Fowler", url: "https://martinfowler.com/feed.atom", site_url: "https://martinfowler.com/",
        category: "personal_blog", tags: %w[architecture patterns], featured: true },
      { name: "Coding Horror", url: "http://feeds.feedburner.com/codinghorror",
        site_url: "https://blog.codinghorror.com/", category: "personal_blog", tags: %w[engineering culture], featured: true },
      { name: "Joel on Software", url: "https://www.joelonsoftware.com/feed/",
        site_url: "https://www.joelonsoftware.com/", category: "personal_blog", tags: %w[engineering management], featured: false },
      { name: "Antirez", url: "http://antirez.com/rss", site_url: "http://antirez.com/", category: "personal_blog",
        tags: %w[redis databases systems], featured: true },
      { name: "Brendan Gregg", url: "http://www.brendangregg.com/blog/rss.xml",
        site_url: "http://www.brendangregg.com/blog/", category: "personal_blog", tags: %w[performance linux systems], featured: true },
      { name: "Aphyr (Kyle Kingsbury)", url: "https://aphyr.com/posts.atom", site_url: "https://aphyr.com/",
        category: "personal_blog", tags: %w[distributed-systems databases testing], featured: true },
      { name: "Filippo Valsorda", url: "https://blog.filippo.io/rss/", site_url: "https://blog.filippo.io/",
        category: "personal_blog", tags: %w[security cryptography go], featured: false },
      { name: "Eli Bendersky", url: "https://eli.thegreenplace.net/feeds/all.atom.xml",
        site_url: "https://eli.thegreenplace.net/", category: "personal_blog", tags: %w[compilers go python], featured: false },
      { name: "Daniel Lemire", url: "https://lemire.me/blog/feed/", site_url: "https://lemire.me/blog/",
        category: "personal_blog", tags: %w[performance databases], featured: false },
      { name: "Tania Rascia", url: "https://tania.dev/rss.xml", site_url: "https://tania.dev/",
        category: "personal_blog", tags: %w[frontend javascript], featured: false },
      { name: "Nelson Elhage", url: "https://blog.nelhage.com/atom.xml", site_url: "https://blog.nelhage.com/",
        category: "personal_blog", tags: %w[systems infrastructure], featured: false },
      { name: "Pat Shaughnessy", url: "http://feeds2.feedburner.com/patshaughnessy",
        site_url: "http://patshaughnessy.net/", category: "personal_blog", tags: %w[ruby compilers], featured: false },
      { name: "Sam Saffron", url: "http://samsaffron.com/posts.rss", site_url: "https://samsaffron.com/",
        category: "personal_blog", tags: %w[ruby performance], featured: false },
      { name: "Daniel Stenberg", url: "https://daniel.haxx.se/blog/feed/", site_url: "https://daniel.haxx.se/blog/",
        category: "personal_blog", tags: %w[networking open-source], featured: false },
      { name: "Armin Ronacher", url: "http://lucumr.pocoo.org/feed.atom", site_url: "http://lucumr.pocoo.org/",
        category: "personal_blog", tags: %w[python rust], featured: false },

      # === Language & Framework blogs ===
      { name: "Go Blog", url: "https://go.dev/blog/feed.atom", site_url: "https://go.dev/blog/",
        category: "language_framework", tags: %w[go], featured: true },
      { name: "Rust Blog", url: "https://blog.rust-lang.org/feed.xml", site_url: "https://blog.rust-lang.org/",
        category: "language_framework", tags: %w[rust], featured: true },
      { name: "V8 Blog", url: "https://v8.dev/blog.atom", site_url: "https://v8.dev/", category: "language_framework",
        tags: %w[javascript performance], featured: false },
      { name: "Mozilla Hacks", url: "https://hacks.mozilla.org/feed/", site_url: "https://hacks.mozilla.org/",
        category: "language_framework", tags: %w[javascript web], featured: false },
      { name: "Ruby News", url: "https://www.ruby-lang.org/en/feeds/news.rss",
        site_url: "https://www.ruby-lang.org/en/news/", category: "language_framework", tags: %w[ruby], featured: false },
      { name: "Node.js Blog", url: "https://nodejs.org/en/feed/blog.xml", site_url: "https://nodejs.org/en/blog/",
        category: "language_framework", tags: %w[javascript node], featured: false },
      { name: "React Blog", url: "https://reactjs.org/feed.xml", site_url: "https://react.dev/blog",
        category: "language_framework", tags: %w[react javascript frontend], featured: false },
      { name: "Laravel News", url: "https://feed.laravel-news.com/", site_url: "https://laravel-news.com/",
        category: "language_framework", tags: %w[php laravel], featured: false },

      # === Lobste.rs frequent sources ===
      { name: "LWN.net", url: "https://lwn.net/headlines/rss", site_url: "https://lwn.net/", category: "news",
        tags: %w[linux kernel], featured: true },
      { name: "Phoronix", url: "https://www.phoronix.com/rss.php", site_url: "https://www.phoronix.com/",
        category: "news", tags: %w[linux hardware performance], featured: false },
      { name: "Bruce Schneier", url: "https://www.schneier.com/feed/atom/", site_url: "https://www.schneier.com/",
        category: "personal_blog", tags: %w[security cryptography], featured: true },
      { name: "matklad", url: "https://matklad.github.io/feed.xml", site_url: "https://matklad.github.io/",
        category: "personal_blog", tags: %w[rust compilers], featured: false },
      { name: "wingolog", url: "https://wingolog.org/feed/atom", site_url: "https://wingolog.org/",
        category: "personal_blog", tags: %w[compilers javascript], featured: false },
      { name: "Chris Siebenmann", url: "https://utcc.utoronto.ca/~cks/space/blog?atom",
        site_url: "https://utcc.utoronto.ca/~cks/space/blog/", category: "personal_blog", tags: %w[linux systems], featured: false },
      { name: "Max Bernstein", url: "https://bernsteinbear.com/feed.xml", site_url: "https://bernsteinbear.com/",
        category: "personal_blog", tags: %w[compilers python], featured: false },
      { name: "Soatok", url: "https://soatok.blog/feed/", site_url: "https://soatok.blog/", category: "personal_blog",
        tags: %w[security cryptography], featured: false },
      { name: "Nick Tietz", url: "https://ntietz.com/atom.xml", site_url: "https://ntietz.com/",
        category: "personal_blog", tags: %w[rust systems], featured: false },
      { name: "Ars Technica", url: "https://feeds.arstechnica.com/arstechnica/index",
        site_url: "https://arstechnica.com/", category: "news", tags: %w[technology], featured: false },
      { name: "Hillel Wayne", url: "https://www.hillelwayne.com/index.xml", site_url: "https://www.hillelwayne.com/",
        category: "personal_blog", tags: %w[formal-methods testing], featured: false },
      { name: "Andrew Nesbitt", url: "https://nesbitt.io/feed.xml", site_url: "https://nesbitt.io/",
        category: "personal_blog", tags: %w[open-source ruby], featured: false },
      { name: "Mat Duggan", url: "https://matduggan.com/rss/", site_url: "https://matduggan.com/",
        category: "personal_blog", tags: %w[infrastructure linux], featured: false },
      { name: "Ladybird Browser", url: "https://ladybird.org/feed.xml", site_url: "https://ladybird.org/",
        category: "company_blog", tags: %w[web browsers open-source], featured: false },
      { name: "htmx", url: "https://htmx.org/feed.xml", site_url: "https://htmx.org/", category: "language_framework",
        tags: %w[frontend web], featured: false },

      # === Curated newsletters / communities ===
      { name: "The Pragmatic Engineer", url: "https://newsletter.pragmaticengineer.com/feed",
        site_url: "https://newsletter.pragmaticengineer.com/", category: "news",
        tags: %w[engineering management startups ai], featured: true },
      { name: "Pointer", url: "https://www.pointer.io/rss/", site_url: "https://www.pointer.io/",
        category: "news", tags: %w[engineering management architecture], featured: true },
      { name: "Lobsters", url: "https://lobste.rs/rss", site_url: "https://lobste.rs/",
        category: "news", tags: %w[community programming open-source], featured: true },

      # === Reddit tech streams (RSS) ===
      { name: "/r/programming", url: "https://www.reddit.com/r/programming/.rss",
        site_url: "https://www.reddit.com/r/programming/", category: "news",
        tags: %w[reddit programming community], featured: false },
      { name: "/r/technology", url: "https://www.reddit.com/r/technology/.rss",
        site_url: "https://www.reddit.com/r/technology/", category: "news",
        tags: %w[reddit technology], featured: false },
      { name: "/r/webdev", url: "https://www.reddit.com/r/webdev/.rss",
        site_url: "https://www.reddit.com/r/webdev/", category: "language_framework",
        tags: %w[reddit frontend web], featured: false },
      { name: "/r/devops", url: "https://www.reddit.com/r/devops/.rss",
        site_url: "https://www.reddit.com/r/devops/", category: "company_blog",
        tags: %w[reddit devops infrastructure], featured: false },
      { name: "/r/machinelearning", url: "https://www.reddit.com/r/MachineLearning/.rss",
        site_url: "https://www.reddit.com/r/MachineLearning/", category: "news",
        tags: %w[reddit ai machine-learning], featured: false }
    ]

    created = 0
    skipped = 0

    new_feeds.each do |data|
      if Feed.exists?(url: data[:url])
        skipped += 1
        next
      end

      feed = Feed.create!(
        name: data[:name],
        url: data[:url],
        site_url: data[:site_url],
        category: data[:category],
        featured: data[:featured]
      )

      data[:tags].each do |tag_name|
        tag = Tag.find_or_create_by!(name: tag_name) { |t| t.slug = tag_name.parameterize }
        FeedTag.find_or_create_by!(feed: feed, tag: tag)
      end

      created += 1
      puts "  + #{data[:name]} (#{data[:category]}, tags: #{data[:tags].join(', ')})"
    end

    puts "\nCreated #{created} feeds, skipped #{skipped} (already exist)."
    puts "Total: #{Feed.count} feeds, #{Tag.count} tags."
  end

  desc "List all feeds with status"
  task list: :environment do
    Feed.order(:name).each do |f|
      status = f.active? ? "active" : "inactive"
      fetched = f.last_fetched_at ? f.last_fetched_at.strftime("%Y-%m-%d %H:%M") : "never"
      errors = f.error_count.positive? ? " (#{f.error_count} errors: #{f.last_error})" : ""
      posts = f.posts.count
      puts "  [#{status}] #{f.name} — #{posts} posts, last fetched: #{fetched}#{errors}"
    end
    puts "\nTotal: #{Feed.count} feeds (#{Feed.active.count} active)"
  end
end
