namespace :stripe do
  desc "Create Robin Pro products and prices in Stripe. Outputs ENV var values to add."
  task setup: :environment do
    abort "STRIPE_SECRET_KEY is not set" unless ENV["STRIPE_SECRET_KEY"].present?

    puts "Creating Robin Pro product..."
    product = Stripe::Product.create(
      name: "Robin Pro",
      description: "ツイート500文字、プロバッジ、誰にでもDM、優先表示",
      metadata: { app: "robin" }
    )
    puts "  Product ID: #{product.id}"

    puts "Creating monthly price (¥980/月)..."
    monthly = Stripe::Price.create(
      product: product.id,
      unit_amount: 980,
      currency: "jpy",
      recurring: { interval: "month" },
      nickname: "Robin Pro Monthly"
    )

    puts "Creating yearly price (¥9,800/年)..."
    yearly = Stripe::Price.create(
      product: product.id,
      unit_amount: 9800,
      currency: "jpy",
      recurring: { interval: "year" },
      nickname: "Robin Pro Yearly"
    )

    puts ""
    puts "=" * 60
    puts "Add these to your environment variables:"
    puts "=" * 60
    puts "STRIPE_PRO_MONTHLY_PRICE_ID=#{monthly.id}"
    puts "STRIPE_PRO_YEARLY_PRICE_ID=#{yearly.id}"
    puts "=" * 60
    puts ""
    puts "Next: Add Stripe webhook endpoint in your Stripe Dashboard:"
    puts "  URL:    https://robin.katskouta.one/webhooks/stripe"
    puts "  Events: checkout.session.completed"
    puts "          customer.subscription.updated"
    puts "          customer.subscription.deleted"
    puts "          invoice.payment_failed"
  end
end
