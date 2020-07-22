# app/logic/aws_upload.rb
module AwsUpload
  module_function
  def initialze
    @s3 = Aws::S3::Client.new(
      region: Rails.application.credentials[:aws][:region],
      credentials: Aws::Credentials.new(
        Rails.application.credentials[:aws][:access_key_id],
        Rails.application.credentials[:aws][:secret_access_key]
      )
    )

    @bucket = Rails.application.credentials[:aws][:bucket_name]
  end

  def upload(image, path)
    initialze
    extension = File.extname(image.original_filename)
    new_file_name = "#{SecureRandom.hex(30)}#{extension}"

    @s3.put_object(
      acl: "public-read",
      bucket: @bucket,
      key: "#{path}/#{new_file_name}",
      body: image
    )

    new_file_name
  end

  def delete(key)
    initialze
    return if key.blank?
    @s3.delete_objects(
      bucket: @bucket,
      delete: {
        objects: [
          {key: key}
        ]
      }
    )
  end
end
