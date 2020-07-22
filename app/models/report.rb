class Report < ApplicationRecord
  enum type_id: {
    spam: 1,
    pretending: 2,
    hateful: 3,
    other: 4
  }

  belongs_to :help_request
  belongs_to :offer_request
end
