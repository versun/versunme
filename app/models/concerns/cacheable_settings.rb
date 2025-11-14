module CacheableSettings
  extend ActiveSupport::Concern

  def self.site_info
    current_site_id = Current.site&.id || Site.active.first&.id
    return {} unless current_site_id
    
    Article.cache_with_site("site_info", expires_in: 1.hour) do
      setting = Setting.for_site(Site.find(current_site_id)).first
      return {} unless setting

      {
        title: setting.title,
        description: setting.description,
        author: setting.author,
        url: setting.url,
        head_code: setting.head_code,
        footer: setting.footer,
        custom_css: setting.custom_css,
        social_links: setting.social_links,
        tool_code: setting.tool_code,
        giscus: setting.giscus,
        time_zone: setting.time_zone || "UTC"
      }
    end
  end

  def self.navbar_items
    current_site_id = Current.site&.id || Site.active.first&.id
    return [] unless current_site_id
    
    Article.cache_with_site("navbar_items", expires_in: 1.hour) do
      Page.for_site(Site.find(current_site_id)).published.order(page_order: :desc)
    end
  end

  def self.refresh_site_info
    current_site_id = Current.site&.id || Site.active.first&.id
    Rails.cache.delete("site_info_#{current_site_id}") if current_site_id
  end

  def self.refresh_navbar_items
    current_site_id = Current.site&.id || Site.active.first&.id
    Rails.cache.delete("navbar_items_#{current_site_id}") if current_site_id
  end

  def self.refresh_all
    refresh_site_info
    refresh_navbar_items
  end
end
