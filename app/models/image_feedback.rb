class ImageFeedback < ApplicationRecord
  
  acts_as_paranoid

  belongs_to :feedback
end
