class Api::StripeDevController < ApplicationController

  protect_from_forgery except: :create

  # application_controller stuff that we don't want here...
  skip_before_action :set_locale
  skip_before_action :set_session_stuff
  skip_before_action :log_user_activity

  def create
    if params[:id]
      if params[:dev_name] == 'dan'
        user = User.find_by_email('dan@learnsignal.com')
      elsif params[:dev_name] == 'james'
        user = User.find_by_email('james@learnsignal.com')
      elsif params[:dev_name] == 'philip'
        user = User.find_by_email('philip@learnsignal.com')
      else
        user = User.find_by_email('site.admin@example.com')
      end
      StripeDeveloperCall.create(
              user_id: user.id,
              params_received: params,
              prevent_delete: false
      )
      render text: nil, status: 200
    else
      render text: nil, status: 204 # no content
    end
  rescue => e
    Rails.logger.error "ERROR: Api/StripeV01#Create: Error: #{e.inspect}"
    render text: nil, status: 204 # no content
  end

end
