class User < ApplicationRecord
  before_save :email_downcase
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  validates :name, presence: true, length:
    {maximum: Settings.validates.user.name_length}
  validates :email, presence: true, length:
    {maximum: Settings.validates.user.email_length},
                    format: {with: VALID_EMAIL_REGEX},
                    uniqueness: {case_sensitive: false}

  has_secure_password
  validates :password, presence: true, length:
    {minimum: Settings.validates.user.password_length}

  def email_downcase
    email.downcase!
  end
end
