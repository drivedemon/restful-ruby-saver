class HelpRequestView < ApplicationRecord
  belongs_to :help_request
  belongs_to :user
end
