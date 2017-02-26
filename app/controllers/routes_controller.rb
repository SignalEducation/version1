class RoutesController < ApplicationController

  def root
    if current_user
      redirect_to dashboard_special_link(current_user)
    else
      redirect_to home_url
    end
  end
end