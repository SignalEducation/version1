# frozen_string_literal: true

module Accredible
  class Credentials < Support::Connection
    def create(name, email, group_id)
      path  = 'credentials'
      query = { credential: { recipient: { name: name, email: email },
                              group_id: group_id } }

      service(path, :post, query)
    end

    def details(id)
      path = "credentials/#{id}"

      service(path, :get)
    end

    def by_group(id)
      path  = 'credentials/search'
      query = { group_id: id }

      service(path, :post, query)
    end

    private

    def service(path, method, query = nil)
      response = response(path: path, method: method, query: query)

      if response.code != '200'
        Appsignal.send_error(Exception.new(response.body), {}, 'services')
        Airbrake::AirbrakeLogger.new(Logger.new(STDOUT)).error response.body
      end

      JSON.parse(response.body).merge(status: response.code).with_indifferent_access
    end
  end
end
