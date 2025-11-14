module MultisitePerformance
  extend ActiveSupport::Concern

  included do
    # Cache headers for site-specific content
    before_action :set_site_cache_headers
    
    # ETags for site-specific content
    etag { Current.site&.id }
    etag { Current.user&.id } if respond_to?(:current_user)
  end

  private

  def set_site_cache_headers
    # Set cache headers based on site context
    if Current.site.present?
      # Site-specific content can be cached
      expires_in 5.minutes, public: true
      
      # Add site ID to cache key
      response.headers["X-Site-ID"] = Current.site.id.to_s
      response.headers["X-Site-Subdomain"] = Current.site.subdomain
    else
      # No site context, minimal caching
      expires_in 1.minute, public: true
    end
  end

  # Helper method for caching site-specific actions
  def cache_site_action(cache_key, expires_in: 5.minutes, &block)
    full_cache_key = "#{cache_key}_site_#{Current.site&.id || 'none'}_#{Rails.env}"
    
    if stale?(etag: full_cache_key, last_modified: nil)
      yield
    end
  end

  # Helper for fragment caching with site context
  def cache_site_fragment(name, &block)
    site_suffix = Current.site ? "_site_#{Current.site.id}" : "_no_site"
    cache_key = "#{name}#{site_suffix}_#{Rails.env}"
    
    cache(cache_key, &block)
  end

  # Clear site-specific caches
  def clear_site_performance_caches
    return unless Current.site.present?
    
    # Clear action caches
    Rails.cache.delete_matched("*_site_#{Current.site.id}_#{Rails.env}*")
    
    # Clear fragment caches
    Rails.cache.delete_matched("*_site_#{Current.site.id}_*")
  end
end