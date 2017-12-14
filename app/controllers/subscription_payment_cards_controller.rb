# == Schema Information
#
# Table name: subscription_payment_cards
#
#  id                  :integer          not null, primary key
#  user_id             :integer
#  stripe_card_guid    :string
#  status              :string
#  brand               :string
#  last_4              :string
#  expiry_month        :integer
#  expiry_year         :integer
#  address_line1       :string
#  account_country     :string
#  account_country_id  :integer
#  created_at          :datetime
#  updated_at          :datetime
#  stripe_object_name  :string
#  funding             :string
#  cardholder_name     :string
#  fingerprint         :string
#  cvc_checked         :string
#  address_line1_check :string
#  address_zip_check   :string
#  dynamic_last4       :string
#  customer_guid       :string
#  is_default_card     :boolean          default(FALSE)
#  address_line2       :string
#  address_city        :string
#  address_state       :string
#  address_zip         :string
#  address_country     :string
#

class SubscriptionPaymentCardsController < ApplicationController

  before_action :logged_in_required
  before_action do
    ensure_user_has_access_rights(%w(student_user user_management_access))
  end
  before_action :get_variables

  def create
    @subscription_payment_card = SubscriptionPaymentCard.new(create_params)
    if @subscription_payment_card.save
      flash[:success] = I18n.t('controllers.subscription_payment_cards.create.flash.success')
      redirect_to account_url(anchor: 'payment-details')
    else
      if @subscription_payment_card.errors.any?
        flash[:error] = @subscription_payment_card.errors.first[1]
      else
        flash[:error] = I18n.t('controllers.subscription_payment_cards.create.flash.error')
      end
      redirect_to account_url(anchor: 'add-card-modal')
    end
  end

  def update
    @subscription_payment_card = SubscriptionPaymentCard.find_by_id(params[:id])
    if @subscription_payment_card.update_as_the_default_card
      flash[:success] = I18n.t('controllers.subscription_payment_cards.update.flash.success')
    else
      flash[:error] = I18n.t('controllers.subscription_payment_cards.update.flash.error')
    end
    redirect_to account_url(anchor: 'payment-details')
  end

  def destroy
    @subscription_payment_card = SubscriptionPaymentCard.find_by_id(params[:id])
    if @subscription_payment_card.destroy
      flash[:success] = I18n.t('controllers.subscription_payment_cards.delete.flash.success')
    else
      flash[:error] = I18n.t('controllers.subscription_payment_cards.delete.flash.error')
    end
    redirect_to account_url(anchor: 'payment-details')
  end

  protected

  def create_params
    params.require(:subscription_payment_card).permit(:stripe_token, :user_id)
  end

  def get_variables
    @subscription_payment_card = current_user.subscription_payment_cards.find_by_id(params[:id]) if params[:id]
  end

  def update_params
    params.require(:subscription_payment_card).permit(:make_default_card)
  end

end
