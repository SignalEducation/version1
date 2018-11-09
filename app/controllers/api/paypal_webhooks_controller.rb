class Api::PaypalWebhooksController < Api::BaseController
  protect_from_forgery except: :create

  def create
    # accept and handle the PayPal Webhooks
  end
end
