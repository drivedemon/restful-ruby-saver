class User < ApplicationRecord
  HEADER_CSV = %w{name email earning spending request status}
  COLUMN_CSV = %w{full_name email total_earning total_spending total_request status}
  INFORMATION_HEADER_CSV = %w{name email telephone username profession status}
  INFORMATION_COLUMN_CSV = %w{full_name email telephone username profession_name status}
  HEADER_TYPE = %w{user_information}.freeze
  HEADER_FILE_NAME = %w{users}.freeze
  CSV_FILE_NAME = "%s-#{Date.today}.csv".freeze
  ATTACHMENT_TYPE = "attachment".freeze

  enum status: %i[active inactive banned]

  acts_as_paranoid

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable

  before_create :generate_auth_token
  belongs_to :profession
  has_one_attached :avatar
  has_one :payment
  has_many :chats
  has_many :feedbacks
  has_many :help_requests, dependent: :destroy
  has_many :chat_rooms_self_help_request, through: :help_requests, source: :chat_room
  has_many :other_user_chats_self_help_request, -> (user) { where.not(user_id: user.id) }, through: :chat_rooms_self_help_request, source: :chats
  has_many :help_request_views
  has_many :offer_requests, dependent: :destroy
  has_many :offer_requests_accepted, through: :offer_requests, source: :help_request
  has_many :chat_rooms_self_offer_request, through: :offer_requests, source: :chat_room
  has_many :other_user_chats_self_offer_request, -> (user) { where.not(user_id: user.id) }, through: :chat_rooms_self_offer_request, source: :chats
  has_many :notifications
  has_many :rates

  include GenerateCsv
  include FilterFromHeaderBackOffice

  validates :telephone, format: { with: /\A\d+\z/ }
  validates_presence_of :email, :first_name, :last_name, :profession_id, :telephone, :username
  validates_uniqueness_of :email, :telephone, :username

  def generate_auth_token
    self.auth_token = SecureRandom.uuid
  end

  def jwt(exp = 30.days.from_now)
    JWT.encode(
      { auth_token: self.auth_token, exp: exp.to_i },
      Rails.application.credentials.secret_key_base, "HS256"
    )
  end

  def as_json_with_jwt
    self.slice(:id, :email, :first_name, :last_name, :telephone, :username).merge(
      {
        auth_jwt: jwt
      }
    )
  end

  def update_location(lat, long)
    update(latitude: lat, longitude: long)
  end

  def as_profile_json
    self.slice(
      :id,
      :email,
      :first_name,
      :last_name,
      :image_path,
      :telephone,
      :username,
      :profession,
      :notification_status,
      :notification_status_green,
      :notification_status_yellow,
      :notification_status_red,
      :green_distance_scope,
      :yellow_distance_scope,
      :red_distance_scope
    ).merge(
      rating: rates.average(:score).to_i
    )
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def profession_name
    profession.name
  end
end
