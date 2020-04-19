# frozen_string_literal: true

class MandrillWorker
  include Sidekiq::Worker
  require 'mandrill_client'

  sidekiq_options queue: 'high'

  def perform(message_id)
    message        = Message.find(message_id)
    method_name    = message.template
    template_args  = message.template_params.values

    return unless message&.user&.email

    client    = MandrillClient.new(message.user)
    response  = client.send(method_name, *template_args)
    state     = response.first.fetch('status')

    message.update(mandrill_id: response.first.fetch('_id'), state: state)
  end
end
