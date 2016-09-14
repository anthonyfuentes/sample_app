
class User < ApplicationRecord
  attr_accessor :remember_token
  before_save { email.downcase! }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  has_secure_password
  validates :password,  presence: true, length: { minimum: 6 }
  validates :name,      presence: true, length: { maximum: 50 }
  validates :email,     presence: true, length: { maximum: 255 },
            format: { with: VALID_EMAIL_REGEX },
            uniqueness: { case_sensitive: false }

  # returns hash digest of given string
  def self.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                   BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  # returns random token
  def self.new_token
    SecureRandom.urlsafe_base64
  end

  # sets & saves remember token & remember digest
  def remember
    self.remember_token = self.class.new_token
    update_attribute(:remember_digest, self.class.digest(remember_token))
  end

  # returns true/ false if given token matches digest
  def authenticated?(remember_token)
    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end

  # ends permanent session by forgetting user
  def forget
    update_attribute(:remember_digest, nil)
  end
end
