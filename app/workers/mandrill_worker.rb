# frozen_string_literal: true

class MandrillWorker
  include Sidekiq::Worker
  require 'mandrill_client'

  sidekiq_options queue: 'high'

  def perform(message_id)
    message        = Message.find(message_id)
    method_name    = message.template
    template_args  = message.template_params.values
    template_args << message.unsubscribe_url if message.unsubscribe_url
    template_args << 'learnsignal.com+ec7befe2db@invite.trustpilot.com' if message.include_bcc?
    # The template_params are pulled out in different order than the order they were input to the hstore

    return unless message&.user&.email

    send_message(message, method_name, template_args)
  end

  def send_message(message, method_name, template_args)
    client = MandrillClient.new(message.user)
    retries = 0
    begin
      response = client.send(method_name, *template_args)
      message.update(mandrill_id: response.first.fetch('_id'), state: response.first.fetch('status'))
    rescue Mandrill::Error
      raise if (retries += 1) > 3

      sleep(retries)
      retry
    end
  end
end
