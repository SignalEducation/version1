# frozen_string_literal: true

module Zendesk
  class Requests < Support::Client
    include ActiveModel::Validations
    attr_accessor :name, :email, :subject, :message

    # validations
    validates :name, :email, :subject, :message, presence: true

    def initialize(name, email, subject, message)
      @name    = name
      @email   = email
      @subject = subject
      @message = message

      super()
    end

    def create
      zendesk_api.requests.create!(parser_request_data)
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
