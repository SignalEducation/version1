class Api::StripeV02Controller < Api::BaseController

  protect_from_forgery except: :create

  def create
    raw_json = request.body.read
    event_json = JSON.parse(raw_json) unless raw_json.blank?

    Rails.logger.error "INFO: Api/StripeV02#Create: Notice: event-type: #{event_json["type"]}, api-version: #{event_json["api_version"]}"

    if event_json && StripeApiEvent::KNOWN_PAYLOAD_TYPES.include?(event_json["type"]) && StripeApiEvent::KNOWN_API_VERSIONS.include?(event_json["api_version"])

      StripeApiProcessorWorker.perform_async(event_json["id"],
                                             event_json["api_version"],
                                             account_url)

    end
    render text: nil, status: 204
  rescue => e
    Rails.logger.error "ERROR: Api/StripeV02#Create: Error: #{e.inspect}\nRaw event: #{raw_json}"
    render text: nil, status: 404 # Let Stripe try again to send data
  end
end
