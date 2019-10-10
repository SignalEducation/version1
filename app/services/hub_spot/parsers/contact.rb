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
         { property: 'preferred_exam_body', value: user&.preferred_exam_body&.name }] + subscriptions_statuses(user)
      end

      def subscriptions_statuses(user, statuses = [])
        ExamBody.where(active: true).each do |body|
          subscriptions_for_body = user.subscriptions.for_exam_body(body.id).where.not(state: :pending).order(created_at: :desc)
          statuses << { property: "#{body&.name&.downcase}_status",
                        value: subscriptions_for_body.any? ? subscriptions_for_body.first.user_readable_status : 'Basic' }
        end

        statuses
      end
    end
  end
end
