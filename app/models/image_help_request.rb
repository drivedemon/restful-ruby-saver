class ImageHelpRequest < ApplicationRecord

  acts_as_paranoid
  
  belongs_to :help_request
end
