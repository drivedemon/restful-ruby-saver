class ApplicationRecord < ActiveRecord::Base
  extend Geocoder::Model::ActiveRecord
  self.abstract_class = true
end
