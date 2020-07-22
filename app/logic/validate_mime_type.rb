# app/logic/validate_mime_type.rb
module ValidateMimeType
  module_function

  def each_data(images)
    images.each do |img|
      check_mime_type(img)
    end
  end

  def check_mime_type(image)
    raise BadError.new("Please select image type") unless MimeTypeImage::EXTENSTION_FILE.include? MimeMagic.by_magic(File.open(image)).type
  end
end
