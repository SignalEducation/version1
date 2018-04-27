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

  before_action :logged_in_required, except: [:referral]
  before_action except: [:referral] do
    ensure_user_has_access_rights(%w(user_management_access))
  end
  before_action :get_variables, except: [:referral]

  def index
    @referral_codes = ReferralCode.paginate(per_page: 50, page: params[:page]).all_in_order
  end

  def show
    @referral_code = ReferralCode.find(params[:id])
    @user = User.find(@referral_code.user_id)
    @referral_url = referral_code_sharing_url(@user.referral_code)
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

  def referral
    referral_code = ReferralCode.find_by_code(request.params[:ref_code]) if params[:ref_code]
    if referral_code
      referral_data = request.referrer ? "#{referral_code.code};#{request.referrer}" : referral_code.code

      # Browsers do not send back cookie attributes so we cannot update only value
      # without altering expiration date. Therefore if we detect difference between
      # current referral data and data stored in the cookie we will always save new
      # data and set expiration to next 30 days.
      if referral_code && referral_data != cookies.encrypted[:referral_data]
        cookies.encrypted[:referral_data] = { value: referral_data, expires: 30.days.from_now, httponly: true }
      end
    end
    redirect_to root_url
  end


  protected

  def get_variables
    @layout = 'management'
  end

end
