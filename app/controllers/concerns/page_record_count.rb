require 'active_support/concern'

module PageRecordCount
  extend ActiveSupport::Concern

  def total_record_count(page_number:, current_count:, collection_record:)
    if collection_record.total_pages == collection_record.current_page
      return current_count
    else
      return (page_number.to_i * 10)
    end
  end
end
