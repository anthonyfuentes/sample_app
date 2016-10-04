# encoding: utf-8

class PictureUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick
  process resize_to_limit: [400, 400]

  storage :file
  # uncomment to enable image upload in production
  #Rails.env.production? ? (storage :fog) : (storage :file)

  # override directory where uploaded files will be stored.
  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  # Add a white list of extensions which are allowed to be uploaded
   def extension_white_list
     %w(jpg jpeg gif png)
   end
end
