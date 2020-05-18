# frozen_string_literal: true

module Accredible
  class Groups < Support::Connection
    def details(id)
      path = "issuer/groups/#{id}"

      service(path, :get)
    end

    private

    def service(path, method)
      response = response(path: path, method: method)

      Airbrake::AirbrakeLogger.new(Logger.new(STDOUT)).error response.body if response.code != '200'
      JSON.parse(response.body).merge(status: response.code).with_indifferent_access
    end
  end
end
