class Tweet < ApplicationRecord
  belongs_to :user, counter_cache: :tweets_count
  belongs_to :parent_tweet, class_name: "Tweet", optional: true, counter_cache: :replies_count
  belongs_to :original_tweet, class_name: "Tweet", optional: true, counter_cache: :retweets_count

  has_many :replies, class_name: "Tweet", foreign_key: :parent_tweet_id, dependent: :destroy
  has_many :retweets, class_name: "Tweet", foreign_key: :original_tweet_id, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :liked_by, through: :likes, source: :user
  has_many :bookmarks, dependent: :destroy
  has_many :notifications, as: :notifiable, dependent: :destroy

  has_many_attached :media

  validates :body, presence: true, unless: :retweet?
  validate :body_within_plan_limit, unless: :retweet?
  validate :media_within_size_limit

  scope :original, -> { where(original_tweet_id: nil) }
  scope :top_level, -> { where(parent_tweet_id: nil) }
  scope :recent, -> { order(created_at: :desc) }

  after_create :create_mention_notifications
  after_create :create_reply_notification

  def retweet?
    original_tweet_id.present?
  end

  def reply?
    parent_tweet_id.present?
  end

  def liked_by?(user)
    likes.exists?(user: user)
  end

  def bookmarked_by?(user)
    bookmarks.exists?(user: user)
  end

  def retweeted_by?(user)
    retweets.exists?(user: user)
  end

  private

  def media_within_size_limit
    media.each do |file|
      errors.add(:media, "のファイルサイズは10MB以内にしてください") if file.blob.byte_size > 10.megabytes
    end
  end

  def body_within_plan_limit
    return unless body.present? && user.present?
    limit = user.tweet_char_limit
    errors.add(:body, "は#{limit}文字以内で入力してください") if body.length > limit
  end

  def create_mention_notifications
    return unless body.present?
    body.scan(/@(\w+)/).flatten.uniq.each do |username|
      mentioned_user = User.find_by(username: username)
      next if mentioned_user.nil? || mentioned_user == user
      Notification.create(user: mentioned_user, actor: user, action: :mentioned, notifiable: self)
    end
  end

  def create_reply_notification
    return unless parent_tweet.present?
    return if parent_tweet.user == user
    Notification.create(user: parent_tweet.user, actor: user, action: :replied, notifiable: self)
  end
end
