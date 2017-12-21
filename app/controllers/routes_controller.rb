class RoutesController < ApplicationController

  def root
    if current_user
      redirect_to student_dashboard_url
    else
      redirect_to root_url
    end
  end
end