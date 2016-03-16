# == Schema Information
#
# Table name: referral_codes
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  code       :string(7)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class ReferralCodesController < ApplicationController
  include ApplicationHelper

  before_action :logged_in_required
  before_action only: [:index, :destroy] do
    ensure_user_is_of_type(['admin'])
  end
  before_action only: [:show] do
    ensure_user_is_of_type(['individual_student', 'tutor', 'blogger'])
  end

  def index
    @referral_codes = ReferralCode.paginate(per_page: 50, page: params[:page]).all_in_order
  end

  def show
    @referral_code = ReferralCode.find(params[:id])
    @user = User.find(@referral_code.user_id)
    if current_user == @user
      #Graph Dates Data
      date_to  = Date.parse("#{Proc.new{Time.now}.call}")
      date_from = date_to - 2.months
      date_range = date_from..date_to
      date_months = date_range.map {|d| Date.new(d.year, d.month, 1) }.uniq
      @labels = date_months.map {|d| d.strftime "%B" }

      #Referral Data
      referral_code = ReferralCode.where(user_id: @user.id).last
      total_referrals = ReferredSignup.where(referral_code_id: referral_code.id)
      initial_referrals = total_referrals.where(payed_at: nil)
      converted_referrals = total_referrals.where.not(payed_at: nil)
      @initial_referrals_this_month = initial_referrals.this_month.count
      @initial_referrals_one_month_ago = initial_referrals.one_month_ago.count
      @initial_referrals_two_months_ago = initial_referrals.two_months_ago.count
      @initial_referrals_three_months_ago = initial_referrals.three_months_ago.count
      @converted_referrals_this_month = converted_referrals.this_month.count
      @converted_referrals_one_month_ago = converted_referrals.one_month_ago.count
      @converted_referrals_two_months_ago = converted_referrals.two_months_ago.count
      @converted_referrals_three_months_ago = converted_referrals.three_months_ago.count
    else
      redirect_to root_url
    end
  end

  def destroy
    @referral_code = ReferralCode.where(id: params[:id]).first
    if @referral_code.destroy
      flash[:success] = I18n.t('controllers.referral_codes.destroy.flash.success')
    else
      flash[:error] = I18n.t('controllers.referral_codes.destroy.flash.error')
    end
    redirect_to referral_codes_url
  end

end
