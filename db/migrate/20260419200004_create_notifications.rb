class CreateNotifications < ActiveRecord::Migration[7.1]
  def change
    create_table :notifications do |t|
      t.references :user, null: false, foreign_key: true
      t.references :actor, null: false, foreign_key: { to_table: :users }
      t.integer :action, null: false, default: 0
      t.string :notifiable_type
      t.integer :notifiable_id
      t.datetime :read_at
      t.timestamps
    end
    add_index :notifications, [:notifiable_type, :notifiable_id]
    add_index :notifications, [:user_id, :read_at]
  end
end
