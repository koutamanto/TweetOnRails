class CreatePremiumPosts < ActiveRecord::Migration[7.1]
  def change
    create_table :premium_posts do |t|
      t.references :creator_profile, null: false, foreign_key: true
      t.string  :title,          null: false
      t.text    :body
      t.text    :free_preview
      t.integer :price,          default: 0,     null: false
      t.boolean :published,      default: false, null: false
      t.datetime :published_at
      t.integer :views_count,    default: 0,     null: false
      t.integer :purchases_count, default: 0,    null: false
      t.timestamps
    end
    add_index :premium_posts, [:creator_profile_id, :published_at]
  end
end
