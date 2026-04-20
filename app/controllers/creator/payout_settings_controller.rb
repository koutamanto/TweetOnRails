class Creator::PayoutSettingsController < Creator::BaseController
  before_action :require_creator!

  def show
    @creator_profile = my_creator_profile
    if @creator_profile.payout_enabled?
      @stripe_dashboard_url = @creator_profile.stripe_dashboard_url
    end
  rescue Stripe::StripeError => e
    @stripe_error = e.message
  end

  def update
    @creator_profile = my_creator_profile
    if @creator_profile.update(payout_params)
      redirect_to creator_payout_path, notice: "設定を保存しました"
    else
      render :show, status: :unprocessable_entity
    end
  end

  private

  def payout_params
    params.require(:creator_profile).permit(:tagline, :subscription_price, :accepting_subscribers)
  end
end
