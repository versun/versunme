class Setting < ApplicationRecord
  include MultisiteCacheable
  
  belongs_to :site
  has_rich_text :footer
  before_save :generate_social_links

  validates :site_id, presence: true, uniqueness: true

  # Default scope to filter by current site
  default_scope -> { where(site_id: Current.site&.id || Site.active.first&.id) }
  
  # Override default scope when needed
  scope :for_site, ->(site) { unscope(:where).where(site_id: site.id) }
  scope :unscoped_all, -> { unscope(:where) }
  
  # Get settings for current site
  def self.current_site_settings
    find_by(site_id: Current.site&.id) || new(site_id: Current.site&.id)
  end

  SOCIAL_PLATFORMS = {
    github: {
      icon_path: "github.svg"
    },
    twitter: {
      icon_path: "x-twitter.svg"
    },
    mastodon: {
      icon_path: "mastodon.svg"
    },
    bluesky: {
      icon_path: "bluesky.svg"
    },
    linkedin: {
      icon_path: "linkedin.svg"
    },
    instagram: {
      icon_path: "instagram.svg"
    },
    youtube: {
      icon_path: "youtube.svg"
    },
    facebook: {
      icon_path: "facebook.svg"
    },
    medium: {
      icon_path: "medium.svg"
    },
    stackoverflow: {
      icon_path: "stack-overflow.svg"
    },
    status_page: {
      icon_path: "status.svg"
    },
    web_analytics: {
      icon_path: "chart.svg"
    }
  }.freeze

  private

  def generate_social_links
    return unless social_links.is_a?(Hash)

    social_links.each do |platform, data|
      next if data["url"].blank? || !SOCIAL_PLATFORMS[platform.to_sym]
      data["icon_path"] = SOCIAL_PLATFORMS[platform.to_sym][:icon_path]
    end
  end
end
