class CreateFanSubscriptions < ActiveRecord::Migration[7.1]
  def change
    create_table :fan_subscriptions do |t|
      t.references :subscriber,      null: false, foreign_key: { to_table: :users }
      t.references :creator_profile, null: false, foreign_key: true
      t.string  :stripe_subscription_id
      t.string  :stripe_checkout_session_id
      t.integer :status,             default: 0, null: false
      t.datetime :current_period_end
      t.integer :amount_paid,        default: 0
      t.timestamps
    end
    add_index :fan_subscriptions, [:subscriber_id, :creator_profile_id], unique: true
    add_index :fan_subscriptions, :stripe_subscription_id
    add_index :fan_subscriptions, :stripe_checkout_session_id
  end
end
