class AddCommentsCountToPost < ActiveRecord::Migration[7.1]
  def change
    add_column :posts, :comments_count, :integer, default: 0

    # Set existing counts
    Post.find_each do |post|
      post.update_column(:comments_count, post.comments.count)
    end
  end
end
