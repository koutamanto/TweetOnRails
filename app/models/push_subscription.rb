class PushSubscription < ApplicationRecord
  belongs_to :user

  def to_webpush_subscription
    { endpoint: endpoint, keys: { p256dh: p256dh, auth: auth } }
  end
end
