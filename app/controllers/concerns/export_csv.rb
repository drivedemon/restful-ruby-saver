require 'active_support/concern'

module ExportCsv
  extend ActiveSupport::Concern

  def get_data_csv(collection_record:, parameter_ids:)
    parameter_ids.present? ? collection_record.where(id: parameter_ids) : collection_record.all
  end
end
