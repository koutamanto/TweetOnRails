class CreateTweets < ActiveRecord::Migration[7.1]
  def change
    create_table :tweets do |t|
      t.references :user, null: false, foreign_key: true
      t.text :body
      t.integer :parent_tweet_id
      t.integer :original_tweet_id
      t.integer :likes_count, default: 0, null: false
      t.integer :retweets_count, default: 0, null: false
      t.integer :replies_count, default: 0, null: false
      t.integer :bookmarks_count, default: 0, null: false
      t.timestamps
    end
    add_index :tweets, :parent_tweet_id
    add_index :tweets, :original_tweet_id
    add_index :tweets, [:user_id, :created_at]
  end
end
