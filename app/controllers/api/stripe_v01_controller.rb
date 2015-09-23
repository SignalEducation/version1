class Api::StripeV01Controller < Api::BaseController

  protect_from_forgery except: :create

  def create
    raw_json = request.body.read
    event_json = JSON.parse(raw_json) unless raw_json.blank?
    if event_json && StripeApiEvent::KNOWN_PAYLOAD_TYPES.include?(event_json["type"])
      StripeApiProcessorWorker.perform_async(event_json["id"],
                                             Stripe.api_version,
                                             account_url)
    end
    render text: nil, status: 204
  rescue => e
    Rails.logger.error "ERROR: Api/StripeV01#Create: Error: #{e.inspect}\nRaw event: #{raw_json}"
    render text: nil, status: 404 # Let Stripe try again to send data
  end
end
