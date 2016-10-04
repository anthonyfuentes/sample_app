
class Micropost < ApplicationRecord
  belongs_to  :user
  validates   :user_id, presence: true
  validates   :content, presence: true, length: { maximum: 140 }
  validate    :picture_size
  default_scope -> { order(created_at: :desc) }
  mount_uploader :picture, PictureUploader

  private

    # validates size of an image for upload
    def picture_size
      maximum_size = 4
      if picture.size > maximum_size.megabytes
        errors.add(:picture, "should be less than #{ maximum_size }MB")
      end
    end
end
