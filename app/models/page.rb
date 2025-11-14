class Page < ApplicationRecord
  include MultisiteCacheable
  include MultisiteQueryOptimization
  
  belongs_to :site
  has_rich_text :content
  enum :status, [ :draft, :publish, :schedule, :trash, :shared ]

  validates :title, presence: true
  validates :slug, presence: true
  validates :slug, uniqueness: { scope: :site_id }
  validates :redirect_url, url: true, allow_blank: true
  validates :site_id, presence: true

  # Default scope to filter by current site
  default_scope -> { where(site_id: Current.site&.id || Site.active.first&.id) }

  scope :published, -> { where(status: :publish) }
  scope :by_status, ->(status) { where(status: status) }
  
  # Override default scope when needed
  scope :for_site, ->(site) { unscope(:where).where(site_id: site.id) }
  scope :unscoped_all, -> { unscope(:where) }

  def to_param
    slug
  end

  def redirect?
    redirect_url.present?
  end
end
