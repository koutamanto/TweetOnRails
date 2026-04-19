class Follow < ApplicationRecord
  belongs_to :follower, class_name: "User", counter_cache: :following_count
  belongs_to :following, class_name: "User", counter_cache: :followers_count

  validates :follower_id, uniqueness: { scope: :following_id }
  validate :cannot_follow_self

  after_create :notify_followed_user
  after_destroy :remove_notification

  private

  def cannot_follow_self
    errors.add(:base, "自分自身をフォローすることはできません") if follower_id == following_id
  end

  def notify_followed_user
    Notification.create(user: following, actor: follower, action: :followed)
  end

  def remove_notification
    Notification.where(user: following, actor: follower, action: :followed).destroy_all
  end
end
