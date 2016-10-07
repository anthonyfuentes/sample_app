
class User < ApplicationRecord
  has_many :microposts, dependent: :destroy
  has_many :active_relationships, class_name: "Relationship",
                                 foreign_key: "follower_id",
                                   dependent:   :destroy
  has_many :passive_relationships, class_name: "Relationship",
                                  foreign_key: "followed_id",
                                    dependent: :destroy
  has_many :following, through: :active_relationships,  source: :followed
  has_many :followers, through: :passive_relationships
  attr_accessor   :remember_token, :activation_token, :reset_token
  before_save     :downcase_email
  before_create   :create_activation_digest
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  has_secure_password
  validates :password,  presence: true, length: { minimum: 6 }, allow_nil: true
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

  # send activation email
  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  # activate usrs account
  def activate
    update_columns(activated: true, activated_at: Time.zone.now)
  end

  def create_password_reset_digest
    self.reset_token = User.new_token
    update_columns(reset_digest:  User.digest(reset_token),
                   reset_sent_at: Time.zone.now)
  end

  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  def clear_password_reset
    update_columns(reset_digest: nil, reset_sent_at: nil)
  end

  # sets & saves remember token & remember digest
  def remember
    self.remember_token = self.class.new_token
    update_attribute(:remember_digest, self.class.digest(remember_token))
  end

  # returns true/ false if given token matches digest
  def authenticated?(attribute, token)
    digest = send("#{ attribute }_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end

  # ends permanent session by forgetting user
  def forget
    update_attribute(:remember_digest, nil)
  end

  def days_since_signup
    seconds_per_day = 60 * 60 * 24
    days_since_signup = (created_at - Time.now) / seconds_per_day
    days_since_signup.abs.round
  end

  # returns true if password reset expired
  def password_reset_expired?
    # < "earlier than"
    reset_sent_at < 2.hours.ago
  end

  # returns all of given users microposts
  def feed
    following_ids = "SELECT followed_id FROM relationships
                     WHERE  follower_id = :user_id"
    Micropost.where("user_id IN (#{ following_ids }) OR user_id = :user_id",
                    following_ids: following_ids, user_id: id)
  end

  # follows given user
  def follow(user)
    active_relationships.create(followed_id: user.id)
  end

  # unfollows given user
  def unfollow(user)
    active_relationships.find_by(followed_id: user.id).destroy
  end

  def following?(user)
    following.include?(user)
  end

  private

    def downcase_email
      email.downcase!
    end

    def create_activation_digest
      self.activation_token  = User.new_token
      self.activation_digest = User.digest(activation_token)
    end
end
