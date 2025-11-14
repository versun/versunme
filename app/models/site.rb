class Site < ApplicationRecord
  has_many :articles, dependent: :destroy
  has_many :pages, dependent: :destroy
  has_many :site_settings, dependent: :destroy, class_name: 'Setting'
  has_many :users, dependent: :destroy
  has_many :sessions, dependent: :destroy

  validates :name, presence: true, length: { maximum: 100 }
  validates :subdomain, presence: true, uniqueness: true, 
            format: { with: /\A[a-z0-9-]+\z/, message: "只能包含小写字母、数字和连字符" },
            length: { maximum: 63 }

  scope :active, -> { where(is_active: true) }

  # 序列化和反序列化site_config字段
  serialize :site_config, coder: JSON

  def to_param
    subdomain
  end

  def full_domain
    if subdomain == 'www' || subdomain.blank?
      Rails.application.config.default_domain
    else
      "#{subdomain}.#{Rails.application.config.default_domain}"
    end
  end

  def config_hash
    site_config || {}
  end

  def config(key, default = nil)
    config_hash[key.to_s] || default
  end

  def set_config(key, value)
    self.site_config ||= {}
    self.site_config[key.to_s] = value
  end
end
