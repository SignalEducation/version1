# frozen_string_literal: true

module HubSpot
  class FormContacts < Support::Connection
    def initialize
      super(:form_api)
    end

    def create(data)
      path = "/submissions/v3/integration/submit/#{credentials[:portal_id]}/#{data[:hs_form_id]}/"
      body = Parsers::Contact.new.form_contact(data)

      response = service(path, body)

      return response if response.code == '200'

      Airbrake::AirbrakeLogger.new(Logger.new(STDOUT)).error response.body
    end

    private

    def service(path, body)
      response(path: path, method: 'post', body: body)
    end
  end
end
