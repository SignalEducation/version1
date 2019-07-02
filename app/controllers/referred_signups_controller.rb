# frozen_string_literal: true

class ReferredSignupsController < ApplicationController
  before_action :logged_in_required
  before_action do
    ensure_user_has_access_rights(%w[user_management_access])
  end

  def index
    condition = params[:payed].to_i == 1 ? 'payed_at is not null' : 'payed_at is null'
    @referred_signups = ReferredSignup.where(condition).
                                       paginate(per_page: 50, page: params[:page]).all_in_order
  end

  def edit
    @referred_signup = ReferredSignup.find_by(id: params[:id])
  end

  def update
    @referred_signup = ReferredSignup.find_by(id: params[:id])
    if @referred_signup&.update_attributes(allowed_params)
      flash[:success] = I18n.t('controllers.referred_signups.update.flash.success')
      redirect_to referred_signups_url
    else
      render action: :edit
    end
  end

  def export_referred_signups
    referral_code = ReferralCode.find(params[:id])
    @referred_signups = ReferredSignup.where(referral_code_id: params[:id]).all_in_order

    respond_to do |format|
      format.html
      format.csv { send_data @referred_signups.to_csv }
      format.xls { send_data @referred_signups.to_csv(col_sep: "\t", headers: true), filename: "RefCode-#{referral_code.code}-referred-signups-#{Date.today}.xls" }
    end
  end

  private

  def allowed_params
    params.require(:referred_signup).permit(:payed_at)
  end
end
