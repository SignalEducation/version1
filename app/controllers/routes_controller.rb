class RoutesController < ApplicationController

  def root
    if current_user
      if current_user.corporate_customer?
        redirect_to corporate_customer_url(current_user.corporate_customer)
      else
        redirect_to dashboard_special_link(current_user)
      end
    else
      if !request.subdomain.empty?
        case request.subdomain
          when 'www', '', nil, 'learnsignal', 'staging', 'acca', 'cfa', 'forum', 'jobs', 'courses'
            redirect_to home_url
          else
            redirect_to corporate_home_url
          end
      else
        redirect_to home_url
      end
    end
  end
end