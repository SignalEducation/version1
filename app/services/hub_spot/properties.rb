# frozen_string_literal: true

module HubSpot
  class Properties < Support::Connection
    def initialize
      super(:main_api)
    end

    def exists?(property)
      response = service("/properties/v1/contacts/properties/named/#{property}", 'get')
      response.code == '200'
    end

    private

    def service(path, method, body = nil)
      response(path: path, method: method, body: body, query: { hapikey: credentials[:api_key] })
    end
  end
end
