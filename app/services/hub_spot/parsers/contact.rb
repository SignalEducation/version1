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
          data_array << { email: user.email, properties: parsed.flatten }
        end

        data_array
      end

      def form_contact(data)
        form_data(data)
      end

      def format_hubspot_date(date)
        date&.utc&.beginning_of_day&.to_datetime&.strftime('%Q')
      end

      def form_data(data)
        {
          fields: [
            { name: 'email',     value: data['email'] },
            { name: 'firstname', value: data['first_name'] },
            { name: 'lastname',  value: data['last_name'] }
          ],
          context: {
            "hutk": data['hutk'].presence || nil,
            "pageUri": data['pageURL'],
            "pageName": data['pageTitle']
          },
          legalConsentOptions: {
            consent: {
              consentToProcess: data['consent'],
              text: "I agree to learnsignal's terms and conditions"
            }
          }
        }
      end

      private

      def data(user)
        last_subscription     = user.last_subscription
        last_purchased_course = user.last_purchased_course

        [{ property: 'email',                  value: user.email },
         { property: 'firstname',              value: user.first_name },
         { property: 'lastname',               value: user.last_name },
         { property: 'email_verified',         value: user.email_verified },
         { property: 'ls_created_at',          value: format_hubspot_date(user.created_at) },
         { property: 'date_of_birth',          value: user.date_of_birth },
         { property: 'currency',               value: user&.currency&.name },
         { property: 'country',                value: user&.country&.name },
         { property: 'user_group',             value: user&.user_group&.name },
         { property: 'sub_close_date_2',       value: format_hubspot_date(last_subscription&.created_at) },
         { property: 'sub_payment_interval',   value: last_subscription&.subscription_plan&.interval_name },
         { property: 'sub_exam_body',          value: last_subscription&.subscription_plan&.exam_body&.name },
         { property: 'sub_type',               value: last_subscription&.kind&.humanize },
         { property: 'sub_canceled_at',        value: format_hubspot_date(last_subscription&.cancelled_at) },
         { property: 'sub_cancelation_reason', value: last_subscription&.cancellation_reason },
         { property: 'sub_cancelation_note',   value: last_subscription&.cancellation_note },
         { property: 'sub_renewal_date',       value: format_hubspot_date(last_subscription&.next_renewal_date&.to_datetime) },
         { property: 'last_purchased_course',  value: last_purchased_course&.name },
         { property: 'preferred_exam_body',    value: user&.preferred_exam_body&.name }] + subscriptions_statuses(user)
      end

      def subscriptions_statuses(user, statuses = [])
        ExamBody.where(active: true).each do |body|
          group = Group.find_by(exam_body_id: body.id)
          subscriptions_for_body = user.subscriptions.for_exam_body(body.id).where.not(state: :pending).order(created_at: :desc)
          lifetime_access_for_body = user.orders.for_group(group.id).for_lifetime_access.where(state: :completed).order(created_at: :desc) if group

          account_status =
            if lifetime_access_for_body&.any?
              'Lifetime Membership'
            elsif subscriptions_for_body.any?
              subscriptions_for_body.first.user_readable_status
            else
              'Basic'
            end

          statuses << { property: body&.hubspot_property.parameterize(separator: '_'), value: account_status }
        end

        statuses
      end
    end
  end
end
