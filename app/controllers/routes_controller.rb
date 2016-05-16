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
      if !request.subdomain.empty?
        case request.subdomain
          when 'www', '', nil, 'learnsignal', 'staging', 'acca', 'cfa', 'forum', 'jobs'
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