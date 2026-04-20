class Creator::OnboardingController < Creator::BaseController
  def setup
    @creator_profile = current_user.creator_profile || current_user.build_creator_profile
  end

  def create_account
    @creator_profile = current_user.creator_profile || current_user.build_creator_profile
    if @creator_profile.update(onboarding_params)
      redirect_to creator_dashboard_path, notice: "クリエイタープロフィールを保存しました"
    else
      render :setup, status: :unprocessable_entity
    end
  end

  def stripe_connect
    @creator_profile = current_user.creator_profile
    return redirect_to creator_setup_path, alert: "先にプロフィールを設定してください" unless @creator_profile
    url = @creator_profile.onboarding_url(
      refresh_url: creator_stripe_refresh_url,
      return_url:  creator_stripe_return_url
    )
    redirect_to url, allow_other_host: true
  rescue Stripe::StripeError => e
    redirect_to creator_dashboard_path, alert: "Stripe接続エラー: #{e.message}"
  end

  def stripe_return
    @creator_profile = current_user.creator_profile
    return redirect_to creator_setup_path unless @creator_profile
    account = Stripe::Account.retrieve(@creator_profile.stripe_account_id)
    if account.details_submitted
      @creator_profile.update!(stripe_onboarded: true)
      redirect_to creator_dashboard_path, notice: "Stripeの設定が完了しました！収益の受け取りが可能になりました。"
    else
      redirect_to creator_stripe_connect_path, alert: "Stripeの設定が完了していません。もう一度お試しください。"
    end
  rescue Stripe::StripeError => e
    redirect_to creator_dashboard_path, alert: "Stripe確認エラー: #{e.message}"
  end

  def stripe_refresh
    redirect_to creator_stripe_connect_path
  end

  private

  def onboarding_params
    params.require(:creator_profile).permit(:tagline, :subscription_price, :accepting_subscribers, :cover_image)
  end
end
