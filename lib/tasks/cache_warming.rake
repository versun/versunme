namespace :cache do
  desc "Warm up caches for all active sites"
  task warm_all: :environment do
    puts "Starting cache warming for all active sites..."
    
    start_time = Time.current
    total_sites = 0
    total_operations = 0
    
    Site.active.find_each do |site|
      puts "\nWarming cache for site: #{site.name} (#{site.subdomain})"
      
      # Switch to current site context
      Current.site = site
      
      operations = 0
      
      # Cache site info
      CacheableSettings.site_info
      operations += 1
      puts "  ✓ Site info cached"
      
      # Cache navigation items
      CacheableSettings.navbar_items
      operations += 1
      puts "  ✓ Navigation items cached"
      
      # Cache published articles list
      Article.cache_with_site("articles_list") do
        Article.published.includes(:rich_text_content).order(created_at: :desc).limit(100)
      end
      operations += 1
      puts "  ✓ Articles list cached (#{Article.published.count} articles)"
      
      # Cache RSS feed content
      Article.cache_with_site("rss_feed") do
        Article.published.order(created_at: :desc).limit(50)
      end
      operations += 1
      puts "  ✓ RSS feed cached"
      
      # Cache site statistics
      Article.site_statistics(site)
      operations += 1
      puts "  ✓ Site statistics cached"
      
      # Cache article counts by status
      Article.article_counts_by_status(site)
      operations += 1
      puts "  ✓ Article counts cached"
      
      # Cache recent content
      Article.recent_content(site, limit: 10)
      operations += 1
      puts "  ✓ Recent content cached"
      
      # Cache navigation data
      Article.navigation_data(site)
      operations += 1
      puts "  ✓ Navigation data cached"
      
      # Cache individual article show pages for popular articles
      popular_articles = Article.published.order(created_at: :desc).limit(5)
      popular_articles.each do |article|
        Rails.cache.fetch("article_#{article.id}_show_#{Rails.env}", expires_in: 1.hour) do
          { article: article, related_articles: [] }
        end
      end
      operations += popular_articles.count
      puts "  ✓ Popular article pages cached (#{popular_articles.count} articles)"
      
      total_sites += 1
      total_operations += operations
      puts "  Total operations for #{site.name}: #{operations}"
    end
    
    # Reset Current.site
    Current.site = nil
    
    end_time = Time.current
    duration = end_time - start_time
    
    puts "\n" + "=" * 60
    puts "✅ Cache warming completed successfully!"
    puts "  Sites processed: #{total_sites}"
    puts "  Total operations: #{total_operations}"
    puts "  Duration: #{duration.round(2)} seconds"
    puts "  Average per site: #{(duration / total_sites).round(2)} seconds"
  end

  desc "Clear all site-specific caches"
  task clear_all: :environment do
    puts "Clearing all site-specific caches..."
    
    cache_patterns = [
      "site_info_*",
      "navbar_items_*",
      "articles_list_*",
      "rss_feed_*",
      "site_statistics_*",
      "article_counts_by_status_*",
      "recent_content_*",
      "popular_content_*",
      "navigation_data_*",
      "article_*_show_*"
    ]
    
    total_deleted = 0
    
    cache_patterns.each do |pattern|
      keys = Rails.cache.instance_variable_get(:@data).keys.select { |k| k.match?(/#{pattern}/) } rescue []
      keys.each do |key|
        Rails.cache.delete(key)
        total_deleted += 1
      end
    end
    
    # Clear site-specific caches for each site
    Site.find_each do |site|
      Article.clear_site_caches(site.id)
    end
    
    puts "✅ Cleared #{total_deleted} cache entries"
  end

  desc "Show cache statistics"
  task stats: :environment do
    puts "Cache Statistics for Multisite"
    puts "=" * 50
    
    Site.active.find_each do |site|
      Current.site = site
      
      puts "\nSite: #{site.name} (#{site.subdomain})"
      
      # Check if caches exist
      caches = [
        { name: "Site Info", key: Article.site_cache_key("site_info") },
        { name: "Navigation Items", key: Article.site_cache_key("navbar_items") },
        { name: "Articles List", key: Article.site_cache_key("articles_list") },
        { name: "RSS Feed", key: Article.site_cache_key("rss_feed") },
        { name: "Site Statistics", key: Article.site_cache_key("site_statistics") }
      ]
      
      caches.each do |cache|
        exists = Rails.cache.exist?(cache[:key])
        puts "  #{cache[:name]}: #{exists ? '✅ Cached' : '❌ Not cached'}"
      end
    end
    
    Current.site = nil
  end
end