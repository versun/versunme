module MultisiteCacheable
  extend ActiveSupport::Concern

  included do
    # After save callbacks to clear site-specific caches
    after_save :clear_multisite_caches
    after_destroy :clear_multisite_caches
  end

  class_methods do
    # Generate cache key for current site
    def site_cache_key(prefix, site_id = nil)
      current_site_id = site_id || Current.site&.id || Site.active.first&.id
      "#{prefix}_site_#{current_site_id}_#{Rails.env}"
    end

    # Cache with site context
    def cache_with_site(prefix, expires_in: 1.hour, &block)
      cache_key = site_cache_key(prefix)
      Rails.cache.fetch(cache_key, expires_in: expires_in, &block)
    end

    # Clear all caches for a specific site
    def clear_site_caches(site_id)
      cache_prefixes = [
        "articles_list",
        "pages_list", 
        "site_info",
        "navbar_items",
        "article_counts",
        "page_counts",
        "site_stats"
      ]
      
      cache_prefixes.each do |prefix|
        Rails.cache.delete(site_cache_key(prefix, site_id))
      end
    end
  end

  private

  def clear_multisite_caches
    site_id = self.respond_to?(:site_id) ? self.site_id : Current.site&.id
    return unless site_id

    # Clear site-specific caches
    self.class.clear_site_caches(site_id)
    
    # Clear related caches
    CacheableSettings.refresh_site_info
    CacheableSettings.refresh_navbar_items
  end
end