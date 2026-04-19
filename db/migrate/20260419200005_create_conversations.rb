class CreateConversations < ActiveRecord::Migration[7.1]
  def change
    create_table :conversations do |t|
      t.timestamps
    end

    create_table :conversation_participants do |t|
      t.references :conversation, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.timestamps
    end
    add_index :conversation_participants, [:conversation_id, :user_id], unique: true

    create_table :messages do |t|
      t.references :conversation, null: false, foreign_key: true
      t.integer :sender_id, null: false
      t.text :body, null: false
      t.datetime :read_at
      t.timestamps
    end
    add_index :messages, :sender_id
    add_foreign_key :messages, :users, column: :sender_id
  end
end
