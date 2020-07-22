# config/initializers/s3.rb
require 'aws-sdk-s3'

Aws.config.update(
  {
    region: Rails.application.credentials[:aws][:region],
    credentials: Aws::Credentials.new(
      Rails.application.credentials[:aws][:access_key_id],
      Rails.application.credentials[:aws][:secret_access_key]
    )
  }
)

S3_BUCKET = Aws::S3::Resource.new.bucket(Rails.application.credentials[:aws][:bucket_name])
