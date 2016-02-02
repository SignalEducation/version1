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
  before_action only: [:create] do
    ensure_user_is_of_type(['individual_student', 'corporate_student', 'tutor', 'blogger'])
  end

  def index
    @referral_codes = ReferralCode.paginate(per_page: 50, page: params[:page]).all_in_order
  end

  def create
    respond_to do |format|
      format.html { redirect_to root_url }
      format.js {
        if current_user.admin?
          render json: { message: I18n.t('controllers.application.you_are_not_permitted_to_do_that') }, status: 422
        elsif current_user.referral_code
          render json: { message: I18n.t('controllers.referral_codes.create.flash.error') }, status: 422
        else
          referral_code = current_user.create_referral_code
          render json: { url: referral_code_sharing_url(referral_code) }.to_json
        end
      }
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
