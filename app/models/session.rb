class Session < ApplicationRecord
  belongs_to :user
  belongs_to :site
  
  validates :site_id, presence: true
end
