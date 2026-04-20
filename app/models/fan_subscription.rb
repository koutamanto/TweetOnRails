class FanSubscription < ApplicationRecord
  belongs_to :subscriber,      class_name: "User"
  belongs_to :creator_profile

  enum status: { pending: 0, active: 1, cancelled: 2, past_due: 3 }

  scope :active,        -> { where(status: :active) }
  scope :active_access, -> {
    where(status: :active)
      .or(where(status: :cancelled).where("current_period_end > ?", Time.current))
  }
end
