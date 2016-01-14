class SubscriptionPaymentCardsController < ApplicationController

  before_action :logged_in_required
  before_action do
    ensure_user_is_of_type(%w(individual_student corporate_customer admin))
  end
  before_action :get_variables

  def create
    @subscription_payment_card = SubscriptionPaymentCard.new(create_params)
    if @subscription_payment_card.save
      flash[:success] = I18n.t('controllers.subscription_payment_cards.create.flash.success')
    else
      flash[:error] = I18n.t('controllers.subscription_payment_cards.create.flash.error')
    end
    redirect_to account_url(anchor: 'payment-details')
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

  protected

  def create_params
    params.require(:subscription_payment_card).permit(:stripe_token, :make_default_card, :user_id)
  end

  def get_variables
    if params[:id]
      @subscription_payment_card = current_user.admin? ?
              SubscriptionPaymentCard.find_by_id(params[:id]) :
              current_user.subscription_payment_cards.find_by_id(params[:id])
    end
  end

  def update_params
    params.require(:subscription_payment_card).permit(:make_default_card)
  end

end
