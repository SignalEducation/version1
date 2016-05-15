class RoutesController < ApplicationController

  def root
    if current_user
      if current_user.corporate_customer?
        custom_root = corporate_customer_url(current_user.corporate_customer)
      else
        custom_root = dashboard_url
      end
      redirect_to custom_root
    else
      redirect_to 'home_pages#show'
    end
  end
end