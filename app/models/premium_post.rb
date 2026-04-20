class PremiumPost < ApplicationRecord
  belongs_to :creator_profile
  has_many_attached :media
  has_many :premium_purchases, dependent: :destroy

  validates :title, presence: true, length: { maximum: 200 }
  validates :price, numericality: { greater_than_or_equal_to: 0 }

  scope :published, -> { where(published: true).order(published_at: :desc) }
  scope :drafts,    -> { where(published: false).order(updated_at: :desc) }

  before_save :set_published_at

  def ppv?
    price > 0
  end

  def accessible_by?(user)
    return false unless user
    return true  if creator_profile.user == user
    return false unless published?
    ppv? ? purchased_by?(user) : subscribed_by?(user)
  end

  def purchased_by?(user)
    return false unless user
    premium_purchases.completed.exists?(buyer: user)
  end

  def subscribed_by?(user)
    return false unless user
    FanSubscription.active_access.exists?(subscriber: user, creator_profile: creator_profile)
  end

  private

  def set_published_at
    self.published_at = Time.current if published? && published_at.nil?
  end
end
