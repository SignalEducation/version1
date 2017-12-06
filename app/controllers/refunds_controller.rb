# == Schema Information
#
# Table name: refunds
#
#  id                 :integer          not null, primary key
#  stripe_guid        :string
#  charge_id          :integer
#  stripe_charge_guid :string
#  invoice_id         :integer
#  subscription_id    :integer
#  user_id            :integer
#  manager_id         :integer
#  amount             :integer
#  reason             :text
#  status             :string
#  livemode           :boolean          default(TRUE)
#  stripe_refund_data :text
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

class RefundsController < ApplicationController

  before_action :logged_in_required
  before_action do
    ensure_user_has_access_rights(%w(user_management_access stripe_management_access))
  end
  before_action :get_variables

  def show
    @refund = Refund.where(id: params[:id]).first
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
      flash[:success] = I18n.t('controllers.refunds.create.flash.success')
      redirect_to refunds_url
    else
      render action: :new
    end
  end

  protected

  def get_variables
    @layout = 'management'
  end

  def allowed_params
    params.require(:refund).permit(:charge_id, :invoice_id, :subscription_id, :user_id, :manager_id, :amount, :reason)
  end

end
