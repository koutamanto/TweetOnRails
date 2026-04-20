class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :actor, class_name: "User"
  belongs_to :notifiable, polymorphic: true, optional: true

  enum action: { liked: 0, followed: 1, retweeted: 2, replied: 3, mentioned: 4 }

  scope :unread, -> { where(read_at: nil) }
  scope :recent, -> { order(created_at: :desc) }

  def read!
    update(read_at: Time.current)
  end

  def unread?
    read_at.nil?
  end

  after_create_commit :push_badge_count

  private

  def push_badge_count
    count = user.notifications.where(read_at: nil).count
    UserChannel.broadcast_to(user, { type: "notif_count", count: count })

    body_text = case action.to_sym
    when :liked     then "#{actor.display_name}さんがあなたのツイートにいいねしました"
    when :followed  then "#{actor.display_name}さんがあなたをフォローしました"
    when :retweeted then "#{actor.display_name}さんがあなたのツイートをリツイートしました"
    when :replied   then "#{actor.display_name}さんがあなたのツイートに返信しました"
    when :mentioned then "#{actor.display_name}さんがあなたをメンションしました"
    end
    target_url = notifiable ? "/tweets/#{notifiable_id}" : "/notifications"
    target_url = "/#{actor.username}" if action.to_sym == :followed

    WebPushService.deliver(user: user, title: "Robin", body: body_text,
                           url: target_url, tag: "notif-#{action}")
  end
end
