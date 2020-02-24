# frozen_string_literal: true

module Zendesk
  class RequestWorker
    include Sidekiq::Worker

    sidekiq_options queue: :high

    def perform(name, email, subject, message)
      ticket = Zendesk::Requests.new(name, email, subject, message)
      ticket.create
    end
  end
end
