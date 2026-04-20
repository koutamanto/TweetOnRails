class PremiumPurchase < ApplicationRecord
  belongs_to :buyer,        class_name: "User"
  belongs_to :premium_post

  enum status: { pending: 0, completed: 1, refunded: 2 }

  scope :completed, -> { where(status: :completed) }
end
