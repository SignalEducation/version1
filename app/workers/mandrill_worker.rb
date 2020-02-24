# frozen_string_literal: true

class MandrillWorker
  include Sidekiq::Worker
  require 'mandrill_client'

  sidekiq_options queue: 'high'

  def perform(user_id, method_name, *template_args)
    user = User.find(user_id)

    return unless user&.email

    client = MandrillClient.new(user)
    client.send(method_name, *template_args)
  end
end
