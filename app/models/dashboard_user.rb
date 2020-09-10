class DashboardUser < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable

  devise :database_authenticatable,
         :recoverable, :rememberable, :validatable, authentication_keys: [:login]

  include FilterFromHeaderBackOffice

  validates_uniqueness_of :email, :username
  validates_presence_of :email, :username, :first_name, :last_name, :dashboard_language
  validates :username, uniqueness: { case_sensitive: false }
  validates_inclusion_of :dashboard_language, in: I18n.available_locales.map(&:to_s)
  validates_inclusion_of :receive_notification, in: [true, false]

  belongs_to :role
  belongs_to :region, optional: true
  has_one_attached :avatar
  has_many :dashboard_notifications

  scope :with_notification_on, -> { where(receive_notification: true) }

  attr_writer :login

  before_destroy :validate_destroy, prepend: true do
    throw(:abort) if errors.present?
  end

  before_create :check_default_region

  #this is to override the devise mailer to send in background using activejob
  #sidekiq should be running
  def send_devise_notification(notification, *args)
    devise_mailer.send(notification, self, *args).deliver_later
  end

  #allow query with both username or email
  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      where(conditions).where(["lower(username) = :value OR lower(email) = :value", { :value => login.downcase }]).first
    else
      if conditions[:username].nil?
        where(conditions).first
      else
        where(username: conditions[:username]).first
      end
    end
  end

  def login
    @login || self.username || self.email
  end

  def super_admin?
    role.alias == "super_admin"
  end

  def admin?
    role.alias == "admin"
  end

  def sales?
    role.alias == "sales"
  end

  private

  def validate_destroy
    superadmin_role = Role.find_by(alias: "super_admin")
    errors.add(:error, "Cannot delete last super admin") if role == superadmin_role && superadmin_role.dashboard_users.count == 1
  end

  def check_default_region
    if region_id.nil?
      region_no = Region.where(timezone: "Europe/Oslo").first_or_create(
        country_iso: "no", 
        timezone: "Europe/Oslo"
      )
      region_id = region_no.id 
    end
  end
end
