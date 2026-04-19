class AddCascadeDeleteToComments < ActiveRecord::Migration[7.1]
  def change
    # Remove the old foreign key constraint
    remove_foreign_key :comments, :posts
    # Re-add it with cascade delete
    add_foreign_key :comments, :posts, on_delete: :cascade
  end
end
