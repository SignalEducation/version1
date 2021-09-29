# frozen_string_literal: true

module Paypal
  class SubscriptionValidation < Paypal::Subscription
    include Rails.application.routes.url_helpers

    class << self
      def run_paypal_sync
        ::Subscription.all_paypal.all_active.each do |sub|
          next unless sub.paypal_subscription_guid

          new(sub).sync_with_paypal
        end
      end
    end

    def sync_with_paypal
      match_with_state unless consistent_states(@agreement.state)
      return unless @agreement.state == 'Active'

      check_outstanding
      # check_annual_renewal if @subscription.subscription_plan.interval_name == 'Yearly'
    end

    private

    def check_annual_renewal
      renewal_date = @agreement.agreement_details&.next_billing_date
      return unless renewal_date && (renewal_date.to_date - Time.zone.today).to_i == 7

      Message.create(
        process_at: Time.zone.now, user_id: @subscription.user.id,
        kind: :account, template: 'send_subscription_notification_email',
        template_params: {
          url: account_url(anchor: 'payment-details', host: ENV.fetch('LEARNSIGNAL_V3_SERVER_EMAIL_DOMAIN', 'localhost:3000'))
        }
      )
    end

    def check_outstanding
      sub_recovery = Paypal::SubscriptionRecovery.new(subscription, agreement)
      return unless sub_recovery.outstanding_balance?

      sub_recovery.bill_outstanding
    end

    def consistent_states(state)
      return false unless STATUSES.key?(state)

      @subscription.send("#{STATUSES[state]}?") && @subscription.paypal_status == state
    end

    def update_paypal_status(status)
      return if @subscription.paypal_status == status

      @subscription.update(paypal_status: status)
    end

    def update_subscription_state(state)
      case state
      when 'Active'
        @subscription.restart!
      when 'Suspended'
        check_suspended_status
      when 'Cancelled'
        check_cancellation_status
      else
        notify_error_monitors
      end
    end

    def check_scheduled_cancellation_worker
      set = Sidekiq::ScheduledSet.new
      return if set.select do |scheduled|
                  scheduled.klass == 'PaypalSubscriptionCancellationWorker' &&
                  scheduled.args[0] == @subscription.id
                end.any?

      PaypalSubscriptionsService.new(@subscription).cancel_billing_agreement_immediately
      notify_cancellation_slack(@subscription)
    end

    def check_suspended_status
      if @subscription.pending_cancellation?
        check_scheduled_cancellation_worker
      else
        @subscription.pause!
      end
    end

    def check_cancellation_status
      return if @subscription.pending_cancellation? && @subscription.next_renewal_date && @subscription.next_renewal_date > Time.zone.now

      @subscription.cancel!
    end

    def update_needed?(state)
      return true unless STATUSES.key?(state)

      STATUSES.key?(state) && !@subscription.send("#{STATUSES[state]}?")
    end

    def match_with_state
      update_paypal_status(@agreement.state)
      update_subscription_state(@agreement.state) if update_needed?(@agreement.state)
    rescue StateMachines::InvalidTransition => e
      log_to_airbrake(e)
    end

    def log_to_airbrake(error)
      Appsignal.send_error(error)
      Airbrake.notify("PAYPAL SYNC ERROR: Subscription #{@subscription.id}: #{error.message}")
    end

    def notify_error_monitors
      error_msg = "PAYPAL SYNC ERROR: Weird PayPal state for subscription #{@subscription.id}"
      Appsignal.send_error(Exception.new(error_msg))
      Airbrake.notify(error_msg)
    end

    def notify_cancellation_slack(subscription)
      slack          = SlackService.new
      message_params = [{ fallback: "Paypay cron job cancelled subscription ##{subscription.id}.",
                          title: "Paypay cron job cancelled subscription ##{subscription.id}.",
                          title_link: "https://learnsignal.com/subscription_management/#{subscription.id}",
                          color: '#7CD197',
                          footer: 'PayPal',
                          ts: subscription.cancelled_at }]

      slack.notify_channel('payments', message_params, icon_emoji: 'rotating_light') if Rails.env.production?
    end
  end
end
