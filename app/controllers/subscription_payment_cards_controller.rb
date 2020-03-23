# frozen_string_literal: true

class SubscriptionPaymentCardsController < ApplicationController
  before_action :logged_in_required
  before_action do
    ensure_user_has_access_rights(%w[student_user user_management_access])
  end
  before_action :set_subscription_payment_card, except: %i[create]

  def create
    @subscription_payment_card = SubscriptionPaymentCard.new(create_params)

    if @subscription_payment_card.save
      flash[:success] = t('controllers.subscription_payment_cards.create.flash.success')
      redirect_to account_url(anchor: 'payment-details')
    else
      flash[:error] =
        if @subscription_payment_card.errors.any?
          @subscription_payment_card.errors.first[1]
        else
          t('controllers.subscription_payment_cards.create.flash.error')
        end
      redirect_to account_url(anchor: 'add-card-modal')
    end
  end

  def update
    if @subscription_payment_card.update_as_the_default_card
      flash[:success] = t('controllers.subscription_payment_cards.update.flash.success')
    else
      flash[:error] = t('controllers.subscription_payment_cards.update.flash.error')
    end

    redirect_to account_url(anchor: 'payment-details')
  end

  def destroy
    if @subscription_payment_card.destroy
      flash[:success] = t('controllers.subscription_payment_cards.delete.flash.success')
    else
      flash[:error] = t('controllers.subscription_payment_cards.delete.flash.error')
    end

    redirect_to account_url(anchor: 'payment-details')
  end

  protected

  def create_params
    params.require(:subscription_payment_card).permit(:stripe_token, :user_id)
  end

  def set_subscription_payment_card
    @subscription_payment_card = SubscriptionPaymentCard.find_by(id: params[:id])
  end
end
