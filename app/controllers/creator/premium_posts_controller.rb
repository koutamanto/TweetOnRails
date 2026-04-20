class Creator::PremiumPostsController < Creator::BaseController
  before_action :require_creator!
  before_action :set_post, only: [:edit, :update, :destroy]

  def index
    @published = my_creator_profile.premium_posts.published
    @drafts    = my_creator_profile.premium_posts.drafts
  end

  def new
    @post = my_creator_profile.premium_posts.build
  end

  def create
    @post = my_creator_profile.premium_posts.build(post_params)
    if @post.save
      redirect_to creator_posts_path, notice: "投稿を保存しました"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @post.update(post_params)
      redirect_to creator_posts_path, notice: "投稿を更新しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @post.destroy
    redirect_to creator_posts_path, notice: "投稿を削除しました"
  end

  private

  def set_post
    @post = my_creator_profile.premium_posts.find(params[:id])
  end

  def post_params
    params.require(:premium_post).permit(:title, :body, :free_preview, :price, :published, media: [])
  end
end
