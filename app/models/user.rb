class User < ApplicationRecord
  belongs_to :site
  has_secure_password
  has_many :sessions, dependent: :destroy
  normalizes :user_name, with: ->(e) { e.strip.downcase }

  validates :site_id, presence: true

  # Default scope to filter by current site
  default_scope -> { where(site_id: Current.site&.id || Site.active.first&.id) }
  
  # Override default scope when needed
  scope :for_site, ->(site) { unscope(:where).where(site_id: site.id) }
  scope :unscoped_all, -> { unscope(:where) }
  
  # Find user by username within current site
  def self.find_by_user_name_within_site(user_name, site = Current.site)
    where(user_name: user_name, site_id: site&.id).first
  end
end
