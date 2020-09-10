class Region < ApplicationRecord
  validates_presence_of :country_iso, :timezone
  validates_uniqueness_of :timezone
  has_many :dashboard_users
end