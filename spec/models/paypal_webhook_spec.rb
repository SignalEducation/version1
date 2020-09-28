# == Schema Information
#
# Table name: paypal_webhooks
#
#  id           :integer          not null, primary key
#  guid         :string
#  event_type   :string
#  payload      :text
#  processed_at :datetime
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  verified     :boolean          default("true")
#

require 'rails_helper'

describe PaypalWebhook do
  # validation
  it { should validate_presence_of(:guid) }
  it { should validate_presence_of(:payload) }
  it { should validate_presence_of(:event_type) }

  it 'has a valid factory' do
    expect(build(:paypal_webhook)).to be_valid
  end

  # callbacks
  it { should callback(:check_dependencies).before(:destroy) }

  describe 'instance methods' do
    let(:paypal_webhook) { create(:paypal_webhook) }
    let(:subscription) { build_stubbed(:subscription) }

    describe '#destroyable?' do
      it 'returns TRUE' do
        expect(paypal_webhook.destroyable?).to be_truthy
      end
    end

    describe '#verify_subscription' do
      it 'sets #verified to TRUE if a subscription exists' do
        allow(Subscription).to receive(:find_by).and_return(subscription)
        expect(paypal_webhook).to receive(:update!).with(verified: true)

        paypal_webhook.verify_subscription('test')
      end

      it 'sets #verified to FALSE if a subscription does not exist' do
        allow(Subscription).to receive(:find_by).and_return(nil)

        expect { paypal_webhook.verify_subscription('test') }.to change { paypal_webhook.verified }.from(true).to(false)
      end
    end

    describe '#process_sale_completed' do
      describe 'for invalid invoices' do
        before :each do
          allow(Invoice).to receive(:build_from_paypal_data).and_return(nil)
        end

        it 'marks the paypal_webhook record as verified: false' do
          expect(paypal_webhook).to receive(:update!).with(verified: false)

          paypal_webhook.process_sale_completed
        end
      end

      describe 'for valid invoices' do
        let(:invoice) { create(:invoice) }

        before :each do
          allow_any_instance_of(SubscriptionPlanService).to receive(:queue_async)
          allow(Invoice).to receive(:build_from_paypal_data).and_return(invoice)
        end

        it 'updates the relevant invoice' do
          expect(invoice).to receive(:update!).with(paid: true, payment_closed: true)

          paypal_webhook.process_sale_completed
        end

        it 'calls update_next_billing_date on the PaypalSubscriptionsService' do
          expect_any_instance_of(PaypalSubscriptionsService).to receive(:update_next_billing_date)

          paypal_webhook.process_sale_completed
        end

        it 'sets the processed_at timestamp' do
          Timecop.freeze(Time.zone.now) do
            expect(paypal_webhook).to receive(:update!).with(processed_at: Time.zone.now)

            paypal_webhook.process_sale_completed
          end
        end

        describe 'for active PayPal subscriptions' do
          before :each do
            @sub_double = double(paypal_status: 'Active', paypal_subscription_guid: nil)
            allow(invoice).to receive(:subscription).and_return(@sub_double)
          end

          it 'does not update the subscription object' do
            expect(@sub_double).not_to receive(:update!)

            paypal_webhook.process_sale_completed
          end
        end

        describe 'for in-active PayPal subscriptions' do
          before :each do
            @sub_double = double(paypal_status: 'Pending', paypal_subscription_guid: nil)
            allow(invoice).to receive(:subscription).and_return(@sub_double)
          end

          it 'updates the paypal_status of the subscription to Active' do
            expect(@sub_double).to receive(:update!).with(paypal_status: 'Active')

            paypal_webhook.process_sale_completed
          end
        end
      end
    end

    describe '#process_sale_denied' do
      describe 'for invalid invoices' do
        before :each do
          allow(Invoice).to receive(:build_from_paypal_data).and_return(nil)
        end

        it 'marks the paypal_webhook record as verified: false' do
          expect(paypal_webhook).to receive(:update!).with(verified: false)

          paypal_webhook.process_sale_denied
        end
      end

      describe 'for valid invoices' do
        let(:invoice) { create(:invoice) }

        before :each do
          allow_any_instance_of(SubscriptionPlanService).to receive(:queue_async)
          allow(Invoice).to receive(:build_from_paypal_data).and_return(invoice)
        end

        it 'updates the relevant invoice' do
          expect(invoice).to receive(:update!).with(paid: false, payment_closed: false)

          paypal_webhook.process_sale_denied
        end

        it 'increments the invoice attempt_count' do
          expect(invoice).to receive(:increment!).with(:attempt_count)

          paypal_webhook.process_sale_denied
        end

        it 'sets the processed_at timestamp' do
          Timecop.freeze(Time.zone.now) do
            expect(paypal_webhook).to receive(:update!).with(processed_at: Time.zone.now)

            paypal_webhook.process_sale_denied
          end
        end

        it 'calls #update_failed_subscription' do
          expect(paypal_webhook).to receive(:update_failed_subscription)

          paypal_webhook.process_sale_denied
        end
      end
    end

    describe '#process_subscription_cancelled' do
      it 'calls #verify_subscription' do
        expect(paypal_webhook).to receive(:verify_subscription)

        paypal_webhook.process_subscription_cancelled
      end
    end

    describe '#process_subscription_suspended' do
      it 'calls #verify_subscription' do
        expect(paypal_webhook).to receive(:verify_subscription)

        paypal_webhook.process_subscription_suspended
      end
    end

    describe '#reprocess' do
      it 'queues a job in the PaypalWebhookReprocessWorker' do
        expect(PaypalWebhookReprocessWorker).to receive(:perform_async).with(paypal_webhook.id)

        paypal_webhook.reprocess
      end
    end

    describe '#update_failed_subscription' do
      let(:invoice) { create(:invoice) }

      before :each do
        allow_any_instance_of(SubscriptionPlanService).to receive(:queue_async)
        allow(Invoice).to receive(:build_from_paypal_data).and_return(invoice)
      end

      it 'records an error on the subscription object' do
        sub_double = double('Subscription')
        allow(Subscription).to receive(:find_by).and_return(sub_double)
        expect(sub_double).to receive(:record_error!)

        paypal_webhook.process_sale_denied
      end

      it 'sends a slack notification' do
        allow(Rails.env).to receive(:production?).and_return(true)
        expect_any_instance_of(SlackService).to receive(:notify_channel)

        paypal_webhook.process_sale_denied
      end
    end
  end
end
