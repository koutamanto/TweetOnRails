Stripe.api_key = ENV["STRIPE_SECRET_KEY"]
Stripe.api_version = "2024-06-20"

STRIPE_TEST_MODE = ENV["STRIPE_SECRET_KEY"].blank? ||
                   ENV["STRIPE_SECRET_KEY"].start_with?("sk_test_")

Rails.logger.info "[Stripe] mode=#{STRIPE_TEST_MODE ? 'TEST' : 'LIVE'}"
