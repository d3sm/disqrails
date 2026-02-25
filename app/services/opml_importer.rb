require "rexml/document"

class OpmlImporter
  def import(xml_string)
    doc = REXML::Document.new(xml_string)
    imported = 0
    skipped = 0

    doc.elements.each("//outline[@xmlUrl]") do |outline|
      xml_url = outline.attributes["xmlUrl"].to_s.strip
      next if xml_url.blank?

      feed = Feed.find_or_initialize_by(url: xml_url)
      feed.name = outline.attributes["text"].to_s.strip.presence || domain_from(xml_url)
      feed.site_url ||= outline.attributes["htmlUrl"].to_s.strip.presence
      feed.source_type = "rss"

      if feed.save
        imported += 1
      else
        skipped += 1
      end
    end

    { imported: imported, skipped: skipped }
  end

  def import_file(path)
    import(File.read(path))
  end

  private

  def domain_from(url)
    URI.parse(url).host.to_s.delete_prefix("www.")
  rescue StandardError
    "unknown"
  end
end
