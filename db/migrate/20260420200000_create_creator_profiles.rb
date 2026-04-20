class CreateCreatorProfiles < ActiveRecord::Migration[7.1]
  def change
    create_table :creator_profiles do |t|
      t.references :user, null: false, foreign_key: true, index: { unique: true }
      t.string  :stripe_account_id
      t.boolean :stripe_onboarded,      default: false, null: false
      t.text    :tagline
      t.integer :subscription_price,    default: 0,     null: false
      t.boolean :accepting_subscribers, default: false, null: false
      t.integer :total_earned_cents,    default: 0,     null: false
      t.timestamps
    end
    add_index :creator_profiles, :stripe_account_id
  end
end
