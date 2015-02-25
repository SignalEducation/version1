class SubscriptionsController < ApplicationController

  before_action :logged_in_required

  def update

  end

  def destroy

  end

  protected

  def updatable_params
    params.require(:subscription).permit(:subscription_plan_id)
  end
end
