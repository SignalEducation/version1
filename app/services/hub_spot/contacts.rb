# frozen_string_literal: true

module HubSpot
  class Contacts < Support::Connection
    def create(user_id)
      user            = User.find(user_id)
      path            = '/contacts/v1/contact'
      user_properties = Parsers::Contact.new.properties(user)

      service(path, 'post', properties: user_properties)
    end

    def batch_create(users_ids, custom_data = {})
      users            = User.where(id: users_ids)
      path             = '/contacts/v1/contact/batch/'
      users_properties = Parsers::Contact.new.batch_properties(users, custom_data)

      service(path, 'post', users_properties)
    end

    private

    def service(path, method, query)
      response(path: path, method: method, query: query)
    end
  end
end
