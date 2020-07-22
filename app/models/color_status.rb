class ColorStatus < ApplicationRecord

  GREEN_SCOPE_STATUS = 1
  YELLOW_SCOPE_STATUS = 2
  RED_SCOPE_STATUS = 3

  has_many :requests
end
