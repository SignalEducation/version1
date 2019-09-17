# frozen_string_literal: true

class RefundsController < ApplicationController
  before_action :logged_in_required
  before_action do
    ensure_user_has_access_rights(%w[user_management_access stripe_management_access])
  end
  before_action :management_layout

  def show
    @refund = Refund.find_by(id: params[:id])
    @user = @refund.user
    @subscription = @refund.subscription
    @invoice = @refund.invoice
    @charge = @refund.charge
  end

  def new
    @refund = Refund.new
    @charge = Charge.where(id: params[:charge_id]).first
    @subscription = Subscription.where(id: params[:subscription_id]).first
    @invoice = Invoice.where(id: params[:invoice_id]).first
    @user = User.where(id: params[:user_id]).first
  end

  def create
    @refund = Refund.new(allowed_params)

    if @refund.save
      redirect_to(subscription_management_invoice_charge_url(@refund.subscription_id, @refund.invoice_id, @refund.charge_id), notice: I18n.t('controllers.refunds.create.flash.success'))
    else
      flash[:error] = I18n.t('controllers.refunds.create.flash.error')
      redirect_to user_path(id: allowed_params[:user_id])
    end
  rescue Learnsignal::PaymentError => e
    redirect_to user_path(id: allowed_params[:user_id]), notice: e.message
  end

  protected

  def allowed_params
    params.require(:refund).permit(:stripe_charge_guid, :charge_id, :invoice_id, :subscription_id, :user_id, :manager_id, :amount, :reason)
  end
end
