class User < ApplicationRecord
  attr_accessor :remember_token, :activation_token, :reset_token, :change_pass
  before_save :email_downcase
  before_create :create_activation_digest

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  validates :name, presence: true, length:
    {maximum: Settings.validates.user.name_length}
  validates :email, presence: true, length:
    {maximum: Settings.validates.user.email_length},
                    format: {with: VALID_EMAIL_REGEX},
                    uniqueness: {case_sensitive: false}

  has_secure_password
  validates :password, presence: true, length:
    {minimum: Settings.validates.user.password_length}, allow_nil: true
  validate :password_empty?

  scope :created_at_desc, ->{order(created_at: :desc)}

  def self.digest string
    cost = BCrypt::Engine::MIN_COST || BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  def self.new_token
    SecureRandom.urlsafe_base64
  end

  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end

  def authenticated? attribute, token
    digest = send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end

  def forget
    update_attribute(:remember_digest, nil)
  end

  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  def activate
    update_attribute(:activated, true)
    update_attribute(:activated_at, Time.zone.now)
  end

  def create_reset_digest
    update_columns(reset_digest: User.digest(User.new_token),
      reset_sent_at: Time.zone.now, updated_at: Time.zone.now)
  end

  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  def password_reset_expired?
    reset_sent_at < 2.hours.ago
  end

  private

  def password_empty?
    errors.add(:password, " is not empty?") if change_pass && password.blank?
  end

  def email_downcase
    email.downcase!
  end

  def create_activation_digest
    self.activation_token  = User.new_token
    self.activation_digest = User.digest(activation_token)
  end
end
