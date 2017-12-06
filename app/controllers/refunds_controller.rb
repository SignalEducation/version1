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
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

class RefundsController < ApplicationController

  before_action :logged_in_required
  before_action do
    ensure_user_is_of_type(['admin'])
  end
  before_action :get_variables

  def index
    @refunds = Refund.paginate(per_page: 50, page: params[:page]).all_in_order
  end

  def show
  end

  def new
    @refund = Refund.new
  end

  def edit
  end

  def create
    @refund = Refund.new(allowed_params)
    @refund.user_id = current_user.id
    if @refund.save
      flash[:success] = I18n.t('controllers.refunds.create.flash.success')
      redirect_to refunds_url
    else
      render action: :new
    end
  end

  def update
    if @refund.update_attributes(allowed_params)
      flash[:success] = I18n.t('controllers.refunds.update.flash.success')
      redirect_to refunds_url
    else
      render action: :edit
    end
  end


  def destroy
    if @refund.destroy
      flash[:success] = I18n.t('controllers.refunds.destroy.flash.success')
    else
      flash[:error] = I18n.t('controllers.refunds.destroy.flash.error')
    end
    redirect_to refunds_url
  end

  protected

  def get_variables
    if params[:id].to_i > 0
      @refund = Refund.where(id: params[:id]).first
    end
    @charges = Charge.all_in_order
    @invoices = Invoice.all_in_order
    @subscriptions = Subscription.all_in_order
    @users = User.all_in_order
    @managers = Manager.all_in_order
  end

  def allowed_params
    params.require(:refund).permit(:stripe_guid, :charge_id, :stripe_charge_guid, :invoice_id, :subscription_id, :user_id, :manager_id, :amount, :reason, :status)
  end

end
