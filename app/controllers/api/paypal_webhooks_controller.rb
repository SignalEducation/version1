class Api::PaypalWebhooksController < Api::BaseController
  protect_from_forgery except: :create

  def create
    @webhook = PaypalWebhooksService.new(request, params[:paypal].to_json)
    if @webhook.valid?
      @webhook.process
      render body: nil, status: 204
    else
      Rails.logger.error "ERROR: Api/Paypal#Create: Unable to verify PayPal webhook: #{request.headers}"
      render body: nil, status: 404
    end
  rescue => e
    Rails.logger.error "ERROR: Api/Paypal#Create: Unable to process PayPal webhook: #{request.headers}"
    render body: nil, status: 404
  end
end
