# == Schema Information
#
# Table name: stripe_api_events
#
#  id            :integer          not null, primary key
#  guid          :string
#  api_version   :string
#  payload       :text
#  processed     :boolean          default(FALSE), not null
#  processed_at  :datetime
#  error         :boolean          default(FALSE), not null
#  error_message :string
#  created_at    :datetime
#  updated_at    :datetime
#

require 'rails_helper'

describe StripeApiEvent do

  describe 'constants' do
    it { expect(StripeApiEvent.const_defined?(:KNOWN_API_VERSIONS)).to eq(true) }
    it { expect(StripeApiEvent.const_defined?(:KNOWN_PAYLOAD_TYPES)).to eq(true) }
    it { expect(StripeApiEvent.const_defined?(:DELAYED_TYPES)).to eq(true) }
  end

  describe 'relationships' do
    it { should have_many(:charges)}
  end

  describe 'validations' do
    it { should validate_presence_of(:guid) }
    xit { should validate_uniqueness_of(:guid) }
    xit { should validate_length_of(:guid).is_at_most(255) }
    it { should validate_inclusion_of(:api_version).in_array(StripeApiEvent::KNOWN_API_VERSIONS) }
    it { should validate_length_of(:api_version).is_at_most(255) }
    it { should validate_presence_of(:payload) }
  end

  describe 'callbacks' do
    it { should callback(:set_default_values).before(:validation).on(:create) }
    it { should callback(:get_data_from_stripe).before(:validation).on(:create) }
    it { should callback(:disseminate_payload).after(:create) }
    it { should callback(:check_dependencies).before(:destroy) }
  end

  describe 'scopes' do
    it { expect(StripeApiEvent).to respond_to(:all_in_order) }
  end

  describe 'class methods' do
    describe '.known_api_version?' do
      it 'returns true for a known API version' do
        expect(StripeApiEvent.known_api_version?('2015-02-18')).to eq true
      end
      it 'returns false for an unknown API version' do
        expect(StripeApiEvent.known_api_version?('2015-02-77')).to eq false
      end
    end

    describe '.known_payload_type?' do
      it 'returns true for a known Stripe event' do
        expect(StripeApiEvent.known_payload_type?('invoice.created')).to eq true
      end
      it 'returns false for an unknown Stripe event' do
        expect(StripeApiEvent.known_payload_type?('invoice.updated')).to eq false
      end
    end

    describe '.processing_delay' do
      it 'returns 5 minutes for a flagged event' do
        expect(StripeApiEvent.processing_delay('invoice.payment_succeeded')).to(
          eq 1.minute
        )
      end
      it 'returns 1 minute for a non-flagged event' do
        expect(StripeApiEvent.processing_delay('invoice.created')).to(
          eq 10.seconds
        )
      end
    end

    describe '.should_process?' do
      it 'returns true if the API version and event type are valid' do
        expect(
          StripeApiEvent.should_process?(
            {'type' => 'invoice.created', 'api_version' => '2015-02-18'}
          )).to eq true
      end

      it 'returns false if the API version is invalid' do
        expect(
          StripeApiEvent.should_process?(
            {'type' => 'invoice.created', 'api_version' => '2015-02-77'}
          )).to eq false
      end

      it 'returns false if the event type is invalid' do
        expect(
          StripeApiEvent.should_process?(
            {'type' => 'invoice.updated', 'api_version' => '2015-02-18'}
          )).to eq false
      end
    end
  end

  describe 'instance methods' do
    it { should respond_to(:destroyable?) }
    it { should respond_to(:disseminate_payload) }
    it { should respond_to(:get_data_from_stripe) }

    describe '#disseminate_payload' do
      describe 'for invoice.created webhook' do
        let(:payload) {{
          type: 'invoice.created', livemode: false, data: { object: 'dummy' }
        }}
        let(:api_event) { build(:stripe_api_event, payload: payload) }

        it 'call #process_invoice_created' do
          expect(api_event).to receive(:process_invoice_created).with(payload)

          api_event.disseminate_payload
        end
      end

      describe 'for invoice.payment_succeeded webhook' do
        let(:payload) {{
          type: 'invoice.payment_succeeded', livemode: false,
          data: { object: { id: 'test_id' }}
        }}
        let(:api_event) { build(:stripe_api_event, payload: payload) }

        it 'call #process_invoice_payment_success' do
          expect(api_event).to(
            receive(:process_invoice_payment_success).with('test_id')
          )

          api_event.disseminate_payload
        end
      end

      describe 'for invoice.payment_failed webhook' do
        let(:payload) {{
          type: 'invoice.payment_failed', livemode: false,
          data: { object: { 
            id: 'test_id', customer: 'test_customer', subscription: 'test_sub',
            next_payment_attempt: 'timestamp'
          }}
        }}
        let(:api_event) { build(:stripe_api_event, payload: payload) }

        it 'call #process_invoice_payment_failed' do
          expect(api_event).to(
            receive(:process_invoice_payment_failed).with(
              'test_customer', 'timestamp', 'test_sub', 'test_id'
            )
          )

          api_event.disseminate_payload
        end
      end

      describe 'for invoice.payment_action_required webhook' do
        let(:payload) {{
          type: 'invoice.payment_action_required', livemode: false,
          data: { object: { id: 'test_id', subscription: 'test_sub_id'}}
        }}
        let(:api_event) { build(:stripe_api_event, payload: payload) }

        it 'call #process_payment_action_required' do
          expect(api_event).to(
            receive(:process_payment_action_required).with('test_id', 'test_sub_id')
          )

          api_event.disseminate_payload
        end
      end

      describe 'for customer.subscription.deleted webhook' do
        let(:payload) {{
          type: 'customer.subscription.deleted', livemode: false,
          data: { object: { id: 'test_id', customer: 'customer', cancel_at_period_end: false } }
        }}
        let(:api_event) { build(:stripe_api_event, payload: payload) }

        it 'call #process_customer_subscription_deleted' do
          expect(api_event).to(
            receive(:process_customer_subscription_deleted).with(
              'customer', 'test_id', false
            )
          )

          api_event.disseminate_payload
        end
      end

      describe 'for charge.succeeded webhook' do
        let(:payload) {{
          type: 'charge.succeeded', livemode: false,
          data: { object: { invoice: 'test' }}
        }}
        let(:api_event) { build(:stripe_api_event, payload: payload) }

        it 'call #process_charge_event' do
          expect(api_event).to(
            receive(:process_charge_event).with('test', { invoice: 'test' })
          )

          api_event.disseminate_payload
        end
      end

      describe 'for charge.failed webhook' do
        let(:payload) {{
          type: 'charge.failed', livemode: false,
          data: { object: { invoice: 'test' }}
        }}
        let(:api_event) { build(:stripe_api_event, payload: payload) }

        it 'call #process_charge_event' do
          expect(api_event).to(
            receive(:process_charge_event).with('test', { invoice: 'test' })
          )

          api_event.disseminate_payload
        end
      end

      describe 'for charge.refunded webhook' do
        let(:payload) {{
          type: 'charge.refunded', livemode: false,
          data: { object: { invoice: 'test' }}
        }}
        let(:api_event) { build(:stripe_api_event, payload: payload) }

        it 'call #process_charge_refunded' do
          expect(api_event).to(
            receive(:process_charge_refunded).with('test', { invoice: 'test' })
          )

          api_event.disseminate_payload
        end
      end

      describe 'for coupon.updated webhook' do
        let(:payload) {{
          type: 'coupon.updated', livemode: false,
          data: { object: { id: 'test_id' }}
        }}
        let(:api_event) { build(:stripe_api_event, payload: payload) }

        it 'call #process_coupon_updated' do
          expect(api_event).to(
            receive(:process_coupon_updated).with('test_id')
          )

          api_event.disseminate_payload
        end
      end

      describe 'for an invalid livemode value' do
        let(:payload) { { type: 'invoice.created', livemode: true } }
        let(:api_event) { build(:stripe_api_event, payload: payload) }

        it 'call #set_process_error' do
          expect(api_event).to receive(:set_process_error)

          api_event.disseminate_payload
        end
      end
    end

    describe '#process_invoice_payment_success' do
      describe 'when no invoice exists' do
        let(:api_event) { build(:stripe_api_event) }
        it 'calls #set_process_error' do
          allow(Invoice).to receive(:find_by).and_return(nil)
          expect(api_event).to receive(:set_process_error)

          api_event.send(:process_invoice_payment_success, 'test_id')
        end
      end

      describe 'when an invoice exists' do
        let(:api_event) { build(:stripe_api_event) }
        let(:invoice) { create(:invoice) }

        before :each do
          allow_any_instance_of(SubscriptionPlanService).to receive(:queue_async)
          allow(api_event).to receive(:get_data_from_stripe)
          allow(Invoice).to receive(:find_by).and_return(invoice)
          allow_any_instance_of(StripeSubscriptionService).to(
            receive(:retrieve_subscription)
          ).and_return(double(status: 'active', current_period_end: Time.now))
        end

        it 'calls #update_from_stripe on the invoice' do
          expect(invoice).to receive(:update_from_stripe)

          api_event.send(:process_invoice_payment_success, 'inv_12345')
        end

        it 'calls #update on the StripeApiEvent' do
          allow(invoice).to receive(:update_from_stripe)
          expect(api_event).to receive(:update!).with(hash_including(
            processed: true, error: false,
            error_message: nil
          ))

          api_event.send(:process_invoice_payment_success, 'inv_12345')
        end

        it 'calls #update_invoice_payment_success on the subscription' do
          allow(invoice).to receive(:update_from_stripe)
          expect(invoice.subscription).to receive(:update_invoice_payment_success)

          api_event.send(:process_invoice_payment_success, 'inv_12345')
        end

        it 'calls #send_receipt on the invoice' do
          allow(invoice).to receive(:update_from_stripe)
          expect(invoice).to receive(:send_receipt)

          api_event.send(:process_invoice_payment_success, 'inv_12345')
        end
      end
    end

    describe '#process_payment_action_required' do
      describe 'when no invoice exists' do
        let(:api_event) { build(:stripe_api_event) }
        it 'calls #set_process_error' do
          allow(Invoice).to receive(:find_by).and_return(nil)
          expect(api_event).to receive(:set_process_error)

          api_event.send(:process_payment_action_required, 'test_id', 'test_sub_id')
        end
      end

      describe 'when an invoice exists' do
        let(:api_event) { build(:stripe_api_event) }
        let(:invoice) { build_stubbed(:invoice) }
        let(:subscription) { build_stubbed(:subscription) }

        before :each do
          allow_any_instance_of(SubscriptionPlanService).to receive(:queue_async)
          allow(api_event).to receive(:get_data_from_stripe)
          allow(Invoice).to receive(:find_by).and_return(invoice)
          allow(Subscription).to receive_message_chain(:in_reverse_created_order, :find_by).and_return(subscription)
          allow(subscription).to receive_message_chain(:invoices, :count).and_return(2)
        end

        it 'calls #mark_required_payment_action on the invoice' do
          expect(invoice).to receive(:mark_payment_action_required)

          api_event.send(:process_payment_action_required, 'inv_12345', 'sub_12345')
        end

        it 'calls #update on the StripeApiEvent' do
          allow(invoice).to receive(:mark_payment_action_required)
          expect(api_event).to receive(:update!).with(hash_including(
                                                        processed: true, error: false,
                                                        error_message: nil
                                                      ))

          api_event.send(:process_payment_action_required, 'inv_12345', 'sub_12345')
        end
      end
    end
  end
end
