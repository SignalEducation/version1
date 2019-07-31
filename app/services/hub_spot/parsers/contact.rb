# frozen_string_literal: true

module HubSpot
  module Parsers
    class Contact
      def properties(user)
        data(user)
      end

      def batch_properties(users, custom_data, data_array = [])
        users.each do |user|
          parsed = data(user)
          parsed << custom_data if custom_data.present?
          data_array << { email: user.email, properties: parsed }
        end

        data_array
      end

      private

      def data(user)
        [{ property: 'email',               value: user.email },
         { property: 'firstname',           value: user.first_name },
         { property: 'lastname',            value: user.last_name },
         { property: 'email_verified',      value: user.email_verified },
         { property: 'date_of_birth',       value: user.date_of_birth },
         { property: 'currency',            value: user&.currency&.name },
         { property: 'country',             value: user&.country&.name },
         { property: 'preferred_exam_body', value: user&.preferred_exam_body&.name }] + subscriptons_statuses(user)
      end

      def subscriptons_statuses(user, statuses = [])
        user.viewable_subscriptions.each do |subscripton|
          statuses << { property: "#{subscripton&.exam_body&.name&.downcase}_status",
                        value: subscripton.user_readable_status }
        end

        statuses
      end
    end
  end
end
