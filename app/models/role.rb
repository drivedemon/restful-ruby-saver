class Role < ApplicationRecord
  AVAILABLE_ROLES = %i[super_admin admin sales].freeze

  validates_uniqueness_of :name, :alias
  validates_presence_of :name, :alias
  validates_inclusion_of :alias, in: AVAILABLE_ROLES.map(&:to_s)

  has_many :dashboard_users
end