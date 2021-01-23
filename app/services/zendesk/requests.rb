# frozen_string_literal: true

module Zendesk
  class Requests < Support::Client
    attr_reader :name, :email, :subject, :message

    def initialize(name, email, subject, message)
      @name    = name
      @email   = email
      @subject = subject
      @message = message

      super()
    end

    def create
      zendesk_api.requests.create!(parser_request_data)
    rescue ZendeskAPI::Error::RecordInvalid => e
      Rails.logger.error e.message
    end

    private

    def parser_request_data
      { subject: subject,
        comment: { body: message },
        requester: { name: name, email: email },
        custom_fields: [{ id: 360005584497, value: name },
                        { id: 360005553538, value: email }] }
    end
  end
end
