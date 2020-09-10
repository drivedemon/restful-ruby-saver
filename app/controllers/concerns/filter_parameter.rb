require 'active_support/concern'

module FilterParameter
  extend ActiveSupport::Concern

  def query_with_params(collection_record:, permitted_filter_params:, permitted_order_params: nil)
    if permitted_filter_params[:amount].present? && split_param_value(amount_param: permitted_filter_params[:amount]).count > 1
      separate_amount_type(permitted_filter_params: permitted_filter_params)
    end

    permitted_filter_params.except(:location, :radius).each do |key, value|
      next unless value.present?
      collection_record = collection_record.public_send("filter_by_#{key}", value)
    end

    collection_record = collection_record.public_send(
      "filter_by_location",
      URI.decode(permitted_filter_params[:location]).gsub(/[^\d,\.]/, ''),
      permitted_filter_params[:radius]
    ) if permitted_filter_params[:location].present?

    collection_record = sort_with_params(
      parameter_query: permitted_order_params,
      collection_record: collection_record
    ) if permitted_order_params && permitted_order_params[:order] && permitted_order_params[:order_by]

    collection_record
  end

  def get_page_parameter(permitted_page_params:)
    permitted_page_params[:page]&.to_i || 1
  end

  def is_filter_date?(permitted_date_params:)
    permitted_date_params[:start_date].present? && permitted_date_params[:end_date].present?
  end

  private

  def sort_with_params(parameter_query:, collection_record:)
    collection_record.public_send("order_by_#{parameter_query[:order_by]}", parameter_query[:order])
  end

  def split_param_value(amount_param:)
    amount_param.split('_')
  end

  def separate_amount_type(permitted_filter_params:)
    amount_param = split_param_value(amount_param: permitted_filter_params[:amount])
    permitted_filter_params["amount_#{amount_param.last}"] = amount_param.first
    permitted_filter_params[:amount] = ""
    permitted_filter_params
  end
end
