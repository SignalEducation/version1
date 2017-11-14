class RoutesController < ApplicationController

  def root
    if current_user
      if current_user.admin?
        redirect_to admin_dashboard_url
      elsif current_user.customer_support_manager?
        redirect_to customer_support_manager_dashboard_url
      elsif current_user.marketing_support_manager?
        redirect_to marketing_manager_dashboard_url
      else
        redirect_to student_dashboard_url
      end
    else
      redirect_to root_url
    end
  end
end