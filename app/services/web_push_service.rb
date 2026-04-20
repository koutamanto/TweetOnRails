class WebPushService
  VAPID = {
    subject:     ENV.fetch("VAPID_SUBJECT",    "mailto:admin@robin.app"),
    public_key:  ENV["VAPID_PUBLIC_KEY"],
    private_key: ENV["VAPID_PRIVATE_KEY"]
  }.freeze

  def self.deliver(user:, title:, body:, url: "/", tag: nil)
    return unless VAPID[:public_key].present? && VAPID[:private_key].present?

    payload = { title: title, body: body, icon: "/icons/icon-192x192.png",
                badge: "/icons/icon-72x72.png", url: url, tag: tag }.compact.to_json

    user.push_subscriptions.find_each do |sub|
      Webpush.payload_send(
        message:  payload,
        endpoint: sub.endpoint,
        p256dh:   sub.p256dh,
        auth:     sub.auth,
        vapid:    VAPID
      )
    rescue Webpush::InvalidSubscription, Webpush::ExpiredSubscription
      sub.destroy
    rescue => e
      Rails.logger.error "[WebPush] #{e.class}: #{e.message}"
    end
  end
end
