module MultisiteQueryOptimization
  extend ActiveSupport::Concern

  included do
    # Add composite indexes for better query performance
    # These should be added via migrations, but we can document them here
  end

  class_methods do
    # Optimized query methods for multisite scenarios
    
    # Get records with minimal queries
    def with_site_optimization(site = nil)
      target_site = site || Current.site
      return none unless target_site
      
      includes(:site)
        .where(site_id: target_site.id)
        .references(:sites)
    end
    
    # Batch load records for multiple sites
    def by_sites(site_ids)
      where(site_id: site_ids)
        .includes(:site)
        .order(:site_id, :created_at)
    end
    
    # Efficient count by site
    def count_by_site
      group(:site_id).count
    end
    
    # Optimized pagination with site context
    def paginate_with_site(page: 1, per_page: 10, site: nil)
      target_site = site || Current.site
      return none unless target_site
      
      where(site_id: target_site.id)
        .includes(:site)
        .paginate(page: page, per_page: per_page)
    end
    
    # Efficient status queries with site context
    def by_status_and_site(status, site = nil)
      target_site = site || Current.site
      return none unless target_site
      
      where(site_id: target_site.id, status: status)
        .includes(:site)
        .order(created_at: :desc)
    end
    
    # Search with site optimization
    def search_with_site_optimization(query, site = nil)
      target_site = site || Current.site
      return none unless target_site
      
      if respond_to?(:search_content)
        search_content(query).where(site_id: target_site.id)
      else
        where(site_id: target_site.id)
          .where("title LIKE ? OR description LIKE ?", "%#{query}%", "%#{query}%")
      end
    end
  end
  
  # Instance methods for performance optimization
  
  # Check if record belongs to current site efficiently
  def in_current_site?
    return false unless respond_to?(:site_id)
    site_id == Current.site&.id
  end
  
  # Get site subdomain without loading site record
  def site_subdomain
    return nil unless respond_to?(:site_id)
    
    Rails.cache.fetch("site_subdomain_#{site_id}", expires_in: 1.hour) do
      Site.where(id: site_id).pluck(:subdomain).first
    end
  end
end