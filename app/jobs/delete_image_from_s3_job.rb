class DeleteImageFromS3Job < ActiveJob::Base
  # Automatically retry jobs that encountered a deadlock
  retry_on ActiveRecord::Deadlocked

  # Most jobs are safe to ignore if the underlying records
  # are no longer available
  discard_on ActiveJob::DeserializationError

  queue_as :default

  def perform(image_url)
    image_key = image_url.gsub("#{S3_BUCKET.url}/", "")
    S3_BUCKET.object(image_key).delete
  end
end
