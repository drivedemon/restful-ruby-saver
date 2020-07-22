class Feedback < ApplicationRecord
  belongs_to :user
  has_many :image_feedbacks
end
