module SiteStatisticsCache
  extend ActiveSupport::Concern

  included do
    # Cache site statistics for better performance
  end

  class_methods do
    # Get cached site statistics
    def site_statistics(site = nil)
      target_site = site || Current.site
      return {} unless target_site
      
      Article.cache_with_site("site_statistics") do
        {
          total_articles: target_site.articles.count,
          published_articles: target_site.articles.published.count,
          draft_articles: target_site.articles.by_status(:draft).count,
          total_pages: target_site.pages.count,
          published_pages: target_site.pages.published.count,
          total_users: target_site.users.count,
          last_article_date: target_site.articles.maximum(:created_at),
          last_page_date: target_site.pages.maximum(:created_at)
        }
      end
    end

    # Get cached article counts by status
    def article_counts_by_status(site = nil)
      target_site = site || Current.site
      return {} unless target_site
      
      Article.cache_with_site("article_counts_by_status") do
        {
          draft: target_site.articles.by_status(:draft).count,
          publish: target_site.articles.by_status(:publish).count,
          schedule: target_site.articles.by_status(:schedule).count,
          trash: target_site.articles.by_status(:trash).count,
          shared: target_site.articles.by_status(:shared).count
        }
      end
    end

    # Get cached recent content
    def recent_content(site = nil, limit: 10)
      target_site = site || Current.site
      return [] unless target_site
      
      Article.cache_with_site("recent_content_#{limit}") do
        target_site.articles.published
                  .includes(:rich_text_content)
                  .order(created_at: :desc)
                  .limit(limit)
      end
    end

    # Get cached popular content (based on some metric)
    def popular_content(site = nil, limit: 10)
      target_site = site || Current.site
      return [] unless target_site
      
      Article.cache_with_site("popular_content_#{limit}") do
        target_site.articles.published
                  .order(created_at: :desc) # For now, use recent as popular
                  .limit(limit)
      end
    end

    # Get cached site navigation data
    def navigation_data(site = nil)
      target_site = site || Current.site
      return {} unless target_site
      
      Article.cache_with_site("navigation_data") do
        {
          pages: target_site.pages.published.order(page_order: :desc),
          categories: [], # Add if you implement categories
          recent_articles: recent_content(target_site, limit: 5),
          site_info: CacheableSettings.site_info
        }
      end
    end
  end

  # Instance methods for statistics
  
  def update_site_statistics
    return unless respond_to?(:site_id)
    
    # Clear site statistics cache when content changes
    Article.clear_site_caches(site_id)
  end
end