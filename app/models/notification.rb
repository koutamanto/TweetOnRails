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
end
