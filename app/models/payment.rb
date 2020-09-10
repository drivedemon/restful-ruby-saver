class Payment < ApplicationRecord
  belongs_to :help_request
  belongs_to :user

  include FilterFromHeaderBackOffice

end
