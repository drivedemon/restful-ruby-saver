require 'active_support/concern'

module MergeImageParam
  extend ActiveSupport::Concern

  def merge_first_row(model_params, image_params)
    if image_params.present?
      model_params.merge(
        {
          image_type: image_params.first[:image_type],
          image_path: image_params.first[:image_path]
        }
      )
    else
      model_params
    end
  end

  def add_or_remove_image_related_model(model, image_params, remove_images_params = nil)
    delete_image_related_model(model, remove_images_params) if remove_images_params.present?
    return if image_params.blank?
    image_params.each do |image|
      model.create(
        image_type: image[:image_type],
        image_path: image[:image_path]
      )
    end
  end

  private

  def delete_image_related_model(model, remove_images_params)
    remove_images_params.each do |image_id|
      image_request = model.find(image_id)
      image_request.destroy
      DeleteImageFromS3Job.perform_later(image_request.image_path)
    end
  end
end
