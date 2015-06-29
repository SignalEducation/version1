class ReferredSignupsController < ApplicationController
  before_action :logged_in_required
  before_action do
    ensure_user_is_of_type(['admin'])
  end

  def index
    @referred_signups = params[:payed].to_i == 1 ?
                          @referred_signups = ReferredSignup
                                              .where("payed_at is not null")
                                              .paginate(per_page: 50, page: params[:page]).all_in_order :
                          @referred_signups = ReferredSignup
                                              .where(payed_at: nil)
                                              .paginate(per_page: 50, page: params[:page]).all_in_order
  end

  def edit
    @referred_signup = ReferredSignup.find_by_id(params[:id])
  end

  def update
    @referred_signup = ReferredSignup.find_by_id(params[:id])
    if @referred_signup && @referred_signup.update_attributes(allowed_params)
      flash[:success] = I18n.t('controllers.referred_signups.update.flash.success')
      redirect_to referred_signups_url
    else
      render action: :edit
    end
  end

  private

  def allowed_params
    params.require(:referred_signup).permit(:payed_at)
  end
end
