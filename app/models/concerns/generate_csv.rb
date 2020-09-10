require 'active_support/concern'

module GenerateCsv
  extend ActiveSupport::Concern

  class_methods do

    def generate_to_csv(header:, column:, records: all, data_type:, information_header: nil, information_column: nil, information_data: nil)
      CSV.generate do |csv|
        include_customer_information(
          csv: csv,
          information_header: information_header,
          information_column: information_column,
          information_data: information_data
        ) if information_header.present? && information_column.present? && information_data.present?

        csv << data_type
        csv << header

        if records.respond_to?(:each)
          records.each do |data_model|
            csv << column.map{ |attr| data_model.send(attr) }
          end
        else
          csv << column.map{ |attr| records.send(attr) }
        end
      end
    end

    def include_customer_information(csv:, information_header:, information_column:, information_data:)
        csv << User::HEADER_TYPE
        csv << information_header
        csv << information_column.map{ |attr| information_data.send(attr) }
        csv << []
    end

  end
end
