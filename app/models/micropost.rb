class Micropost < ApplicationRecord
  mount_uploader :picture, PictureUploader

  belongs_to :user

  validates :user_id, presence: true
  validates :content, presence: true,
    length: {maximum: Settings.validates.micropots.content_length}

  scope :newest, ->{order created_at: :desc}
  scope :feeds, ->(following_ids, id){where("user_id IN (?) OR user_id = ?", following_ids, id)}
end
