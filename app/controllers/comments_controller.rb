class CommentsController < ApplicationController
  before_action :set_post

  def create
    @comment = @post.comments.new(comment_params)

    if @comment.save
      redirect_to @post, notice: "コメントが追加されました"
    else
      redirect_to @post, alert: "コメントの追加に失敗しました"
    end
  end

  def destroy
    @comment = Comment.find(params[:id])
    @post = @comment.post

    if @comment.destroy
      redirect_to @post, notice: "コメントが削除されました"
    else
      redirect_to @post, alert: "コメントの削除に失敗しました"
    end
  end

  private

  def set_post
    @post = Post.find(params[:post_id])
  end

  def comment_params
    params.require(:comment).permit(:body)
  end
end
