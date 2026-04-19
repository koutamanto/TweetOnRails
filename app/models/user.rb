class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable

  has_one_attached :avatar
  has_one_attached :header_image

  has_many :tweets, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :liked_tweets, through: :likes, source: :tweet
  has_many :bookmarks, dependent: :destroy
  has_many :bookmarked_tweets, through: :bookmarks, source: :tweet
  has_many :notifications, dependent: :destroy
  has_many :sent_messages, class_name: "Message", foreign_key: :sender_id, dependent: :destroy

  has_many :follows, foreign_key: :follower_id, dependent: :destroy
  has_many :following, through: :follows, source: :following
  has_many :passive_follows, class_name: "Follow", foreign_key: :following_id, dependent: :destroy
  has_many :followers, through: :passive_follows, source: :follower

  has_many :conversation_participants, dependent: :destroy
  has_many :conversations, through: :conversation_participants

  validates :username, presence: true,
                       uniqueness: { case_sensitive: false },
                       format: { with: /\A[a-zA-Z0-9_]+\z/, message: "英数字とアンダースコアのみ" },
                       length: { minimum: 3, maximum: 20 }
  validates :display_name, presence: true, length: { maximum: 50 }
  validates :bio, length: { maximum: 160 }

  def following?(user)
    following.include?(user)
  end

  def timeline_tweets
    Tweet.where(user: [self] + following.to_a, parent_tweet_id: nil)
         .order(created_at: :desc)
  end
end
