# frozen_string_literal: true

module HubSpot
  class Contacts < Support::Connection
    def initialize
      super(:main_api)
    end

    def create(user_id)
      user            = User.find(user_id)
      path            = '/contacts/v1/contact'
      user_properties = Parsers::Contact.new.properties(user)

      response = service(path, 'post', properties: user_properties)

      if response.code != '200'
        Appsignal.send_error(Exception.new(response.body), {}, 'services')
        Airbrake::AirbrakeLogger.new(Logger.new(STDOUT)).error response.body
      end

      response
    end

    def batch_create(users_ids, custom_data = {})
      users            = User.where(id: users_ids)
      path             = '/contacts/v1/contact/batch/'
      users_properties = Parsers::Contact.new.batch_properties(users, custom_data)

      response = service(path, 'post', users_properties)

      if response.code != '202'
        Appsignal.send_error(Exception.new(response.body), {}, 'services')
        Airbrake::AirbrakeLogger.new(Logger.new(STDOUT)).error response.body
      end

      response
    end

    def search(email)
      path     = "/contacts/v1/contact/email/#{email}/profile"
      response = service(path, 'get', { propertyMode: 'value_only', showListMemberships: 'false' })

      return if response.code == '502'

      parsed = JSON.parse(response.body)

      return parsed if parsed['status'] != 'error'
    end

    private

    def service(path, method, body)
      response(path: path, method: method, body: body, query: { hapikey: credentials[:api_key] })
    end
  end
end
