class Micropost < ApplicationRecord
  mount_uploader :picture, PictureUploader

  belongs_to :user

  validates :user_id, presence: true
  validates :content, presence: true,
    length: {maximum: Settings.validates.micropots.content_length}

  scope :newest, ->{order created_at: :desc}
end
