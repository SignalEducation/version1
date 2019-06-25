namespace :paypal do
  desc 'Looking for missed paypal subscription cancelled webhooks'
  task :requery_cancellation_webhooks => :environment do
    include PayPal::SDK::REST
    puts 'Running command to find missed subscription cancelled webhooks'
    hooks = WebhookEvent.all(
      page_size: 500,
      start_time: "2019-03-04T00:00:00Z",
      end_time: "2019-03-21T00:00:00Z",
      event_type: "BILLING.SUBSCRIPTION.CANCELLED"
    )
    hooks.events.each do |event|
      unless PaypalWebhook.find_by(guid: event.id)
        hook_service = PaypalWebhookService.new
        if hook_service.record_webhook(JSON.parse(event.to_json))
          hook_service.process_webhook
        else
          puts "Unable to process #{event.id}"
        end
      end
    end
  end

  desc 'Looking for missed paypal payment succeeded webhooks'
  task :requery_sale_completed_webhooks => :environment do
    include PayPal::SDK::REST
    puts 'Running command to find missed sale completed webhooks'
    hooks = WebhookEvent.all(
      page_size: 500,
      start_time: "2019-03-04T00:00:00Z",
      end_time: "2019-03-21T00:00:00Z",
      event_type: "PAYMENT.SALE.COMPLETED"
    )
    hooks.events.each do |event|
      unless PaypalWebhook.find_by(guid: event.id)
        hook_service = PaypalWebhookService.new
        if hook_service.record_webhook(JSON.parse(event.to_json))
          hook_service.process_webhook
        else
          puts "Unable to process #{event.id}"
        end
      end
    end
  end
end
