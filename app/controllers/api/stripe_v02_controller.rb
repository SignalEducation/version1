class Api::StripeV02Controller < Api::BaseController

  protect_from_forgery except: :create

  def create
    raw_json = request.body.read
    event_json = JSON.parse(raw_json) unless raw_json.blank?

    Rails.logger.error "INFO: Api/StripeV02#Create: Notice: event-type: #{event_json["type"]}, api-version: #{event_json["api_version"]}" if event_json

    if event_json && StripeApiEvent::KNOWN_PAYLOAD_TYPES.include?(event_json["type"]) && StripeApiEvent::KNOWN_API_VERSIONS.include?(event_json["api_version"])

      existing_events = StripeApiEvent.where(guid: event_json["id"])
      if existing_events.any?
        Rails.logger.error "INFO: Api/StripeV02#Create: Record already exists with that guid/id: event-id: #{event_json['id']}"
      else

        processing_delay = StripeApiEvent::DELAYED_TYPES.include?(event_json["type"]) ? 5.minutes : 1.minutes

        StripeApiProcessorWorker.perform_at(processing_delay, event_json["id"],
                                            event_json["api_version"],
                                            account_url)

      end
    end
    render head: :no_content
  rescue => e
    Rails.logger.error "ERROR: Api/StripeV02#Create: Error: #{e.inspect}\nRaw event: #{raw_json}"
    render head: :no_content # Let Stripe try again to send data
  end
end
