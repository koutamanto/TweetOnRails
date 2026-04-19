class Like < ApplicationRecord
  belongs_to :user
  belongs_to :tweet, counter_cache: :likes_count

  validates :user_id, uniqueness: { scope: :tweet_id }

  after_create :notify_tweet_author
  after_destroy :remove_notification

  private

  def notify_tweet_author
    return if tweet.user == user
    Notification.create(user: tweet.user, actor: user, action: :liked, notifiable: tweet)
  end

  def remove_notification
    Notification.where(user: tweet.user, actor: user, action: :liked, notifiable: tweet).destroy_all
  end
end
