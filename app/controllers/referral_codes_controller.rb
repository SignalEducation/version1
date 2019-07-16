# frozen_string_literal: true

class ReferralCodesController < ApplicationController
  include ApplicationHelper

  before_action :logged_in_required, except: [:referral]
  before_action except: [:referral] do
    ensure_user_has_access_rights(%w[user_management_access])
  end
  before_action :set_layout, except: [:referral]

  def index
    @referral_codes = ReferralCode.paginate(per_page: 50, page: params[:page]).with_children.all_in_order

    @codes =
      if params[:search].to_s.blank?
        @referral_codes.with_children.all_in_order
      else
        @referral_codes.with_children.search(params[:search])
      end
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
    referral_code = ReferralCode.find_by(code: request.params[:ref_code]) if params[:ref_code]
    drop_referral_code_cookie(referral_code) if params[:ref_code] && referral_code
    redirect_to root_url
  end

  def export_referral_codes
    @referral_codes = ReferralCode.with_children.all_in_order

    respond_to do |format|
      format.html
      format.csv { send_data @referral_codes.to_csv() }
      format.xls { send_data @referral_codes.to_csv(col_sep: "\t", headers: true), filename: "referral-codes-#{Date.today}.xls" }
    end
  end

  protected

  def set_layout
    @layout = 'management'
  end
end
