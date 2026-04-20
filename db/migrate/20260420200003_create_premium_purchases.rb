class CreatePremiumPurchases < ActiveRecord::Migration[7.1]
  def change
    create_table :premium_purchases do |t|
      t.references :buyer,        null: false, foreign_key: { to_table: :users }
      t.references :premium_post, null: false, foreign_key: true
      t.string  :stripe_checkout_session_id
      t.string  :stripe_payment_intent_id
      t.integer :amount_paid,   null: false
      t.integer :platform_fee,  null: false
      t.integer :creator_earned, null: false
      t.integer :status,         default: 0, null: false
      t.timestamps
    end
    add_index :premium_purchases, [:buyer_id, :premium_post_id], unique: true
    add_index :premium_purchases, :stripe_checkout_session_id
  end
end
