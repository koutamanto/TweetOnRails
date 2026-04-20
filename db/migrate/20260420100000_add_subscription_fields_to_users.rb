class AddSubscriptionFieldsToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :stripe_customer_id, :string
    add_column :users, :stripe_subscription_id, :string
    add_column :users, :plan, :string, default: "free", null: false
    add_column :users, :subscription_status, :string, default: "inactive"
    add_column :users, :subscription_current_period_end, :datetime

    add_index :users, :stripe_customer_id, unique: true
    add_index :users, :stripe_subscription_id, unique: true
  end
end
