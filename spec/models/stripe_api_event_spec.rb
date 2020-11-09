# == Schema Information
#
# Table name: stripe_api_events
#
#  id            :integer          not null, primary key
#  guid          :string(255)
#  api_version   :string(255)
#  payload       :text
#  processed     :boolean          default("false"), not null
#  processed_at  :datetime
#  error         :boolean          default("false"), not null
#  error_message :string(255)
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
    it { should callback(:sync_data_from_stripe).before(:validation).on(:create) }
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
    it { should respond_to(:sync_data_from_stripe) }

    describe '#destroyable?' do
      let(:event) { build_stubbed(:stripe_api_event, processed: true) }

      it 'returns the negative of the #processed attribute' do
        expect(event.destroyable?).to be false
      end
    end

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

      describe 'for invoice.upcoming webhook' do
        let(:payload) {{
          type: 'invoice.upcoming', livemode: false,
          data: { object: { subscription: 'test_sub_id'}}
        }}
        let(:api_event) { build(:stripe_api_event, payload: payload) }

        xit 'call #process_invoice_upcoming' do
          expect(api_event).to(
            receive(:process_invoice_upcoming).with('test_sub_id')
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

      describe 'for an unknown webhook value' do
        let(:payload) { { type: 'hook.unknown', livemode: false, data: { object: { id: 'test_id' } } } }
        let(:api_event) { build(:stripe_api_event, payload: payload) }

        it 'calls #log_process_error' do
          expect(api_event).to(receive(:log_process_error).with('Unknown event type - hook.unknown'))

          api_event.disseminate_payload
        end
      end

      describe 'for an invalid livemode value' do
        let(:payload) { { type: 'invoice.created', livemode: true } }
        let(:api_event) { build(:stripe_api_event, payload: payload) }

        it 'call #log_process_error' do
          expect(api_event).to receive(:log_process_error)

          api_event.disseminate_payload
        end
      end
    end

    describe '#sync_data_from_stripe' do
      describe 'when a guid exists' do
        let(:api_event) { build_stubbed(:stripe_api_event, guid: 'test-guid') }

        it 'retreives the event from stripe' do
          expect(Stripe::Event).to receive(:retrieve).with('test-guid')
          allow(api_event).to receive(:assign_attributes)

          api_event.sync_data_from_stripe
        end

        it 'assigns the payload attribute' do
          evt_double = double(to_hash: 'test')
          allow(Stripe::Event).to receive(:retrieve).with('test-guid').and_return(evt_double)
          expect(api_event).to receive(:assign_attributes).with(hash_including(payload: 'test'))

          api_event.sync_data_from_stripe
        end
      end

      describe 'without a valid guid' do
        let(:api_event) { build_stubbed(:stripe_api_event, guid: nil) }

        it 'assigns the error attributes' do
          expect(api_event).to receive(:assign_attributes).with(hash_including(error: true))

          api_event.sync_data_from_stripe
        end
      end
    end

    describe '#process_invoice_payment_success' do
      describe 'when no invoice exists' do
        let(:api_event) { build(:stripe_api_event) }
        it 'calls #log_process_error' do
          allow(Invoice).to receive(:find_by).and_return(nil)
          expect(api_event).to receive(:log_process_error)

          api_event.send(:process_invoice_payment_success, 'test_id')
        end
      end

      describe 'when an invoice exists' do
        let(:api_event) { build(:stripe_api_event) }
        let(:invoice) { create(:invoice) }

        before :each do
          allow_any_instance_of(SubscriptionPlanService).to receive(:queue_async)
          allow(api_event).to receive(:sync_data_from_stripe)
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
        it 'calls #log_process_error' do
          allow(Invoice).to receive(:find_by).and_return(nil)
          expect(api_event).to receive(:log_process_error)

          api_event.send(:process_payment_action_required, 'test_id', 'test_sub_id')
        end
      end

      describe 'when an invoice exists' do
        let(:api_event) { build(:stripe_api_event) }
        let(:invoice) { build_stubbed(:invoice) }
        let(:subscription) { build_stubbed(:subscription) }

        before :each do
          allow_any_instance_of(SubscriptionPlanService).to receive(:queue_async)
          allow(api_event).to receive(:sync_data_from_stripe)
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

    describe 'PROTECTED METHODS' do
      let(:api_event) { build_stubbed(:stripe_api_event) }

      describe '#check_dependencies' do
        it 'returns NIL if the record is destroyable?' do
          allow(api_event).to receive(:destroyable?).and_return(true)

          expect(api_event.send(:check_dependencies)).to be nil
        end

        it 'add an error if the record is not destroyable?' do
          allow(api_event).to receive(:destroyable?).and_return(false)

          api_event.send(:check_dependencies)

          expect(api_event.errors.messages[:base].length).to eq 1
        end
      end

      describe '#process_invoice_created' do
        describe 'for a valid invoice' do
          let(:invoice) { build_stubbed(:invoice) }

          before :each do
            allow(Invoice).to receive(:build_from_stripe_data).and_return(invoice)
          end

          it 'updates the record with the processing details' do
            time = Time.zone.now
            Timecop.freeze(time) do
              expect(api_event).to receive(:update!).with({ processed: true, processed_at: time, error: false, error_message: nil })

              api_event.send(:process_invoice_created, { data: { object: 'test-object' } })
            end
          end
        end

        describe 'for an invalid invoice' do
          before :each do
            allow(Invoice).to receive(:build_from_stripe_data)
          end

          it 'calls #log_process_error if there is no matching invoice' do
            expect(api_event).to receive(:log_process_error).with('Error creating invoice')

            api_event.send(:process_invoice_created, { data: { object: 'test-object' } })
          end
        end
      end

      describe '#process_invoice_payment_failed' do
        describe 'with valid data' do
          let(:user) { build_stubbed(:user) }
          let(:sub) { build_stubbed(:subscription) }
          let(:invoice) { build_stubbed(:invoice) }

          before :each do
            allow(User).to receive(:find_by).and_return(user)
            allow_any_instance_of(ActiveRecord::Relation).to receive(:find_by).and_return(sub)
            allow(Invoice).to receive(:find_by).and_return(invoice)
          end

          it 'calls #update_from_stripe on the invoice' do
            allow(api_event).to receive(:update!)
            expect(invoice).to receive(:update_from_stripe).with('inv-guid')

            api_event.send(:process_invoice_payment_failed, 'test-guid', nil, 'sub-guid', 'inv-guid')
          end

          it 'calls #update_from_stripe on the subscription' do
            allow(api_event).to receive(:update!)
            allow(invoice).to receive(:update_from_stripe)
            expect(sub).to receive(:update_from_stripe)

            api_event.send(:process_invoice_payment_failed, 'test-guid', nil, 'sub-guid', 'inv-guid')
          end

          it 'updates the record with the processing details' do
            allow(invoice).to receive(:update_from_stripe)
            time = Time.zone.now
            Timecop.freeze(time) do
              expect(api_event).to receive(:update!).with({ processed: true, processed_at: time, error: false, error_message: nil })

              api_event.send(:process_invoice_payment_failed, 'test-guid', nil, 'sub-guid', 'inv-guid')
            end
          end

          it 'retruns NIL unless stripe_next_attempt is passed in' do
            allow(invoice).to receive(:update_from_stripe)
            allow(api_event).to receive(:update!)

            expect(api_event.send(:process_invoice_payment_failed, 'test-guid', nil, 'sub-guid', 'inv-guid')).to be nil
          end

          describe 'when stripe_next_attempt is passed' do
            before :each do
              allow(invoice).to receive(:update_from_stripe)
              allow(api_event).to receive(:update!)
            end

            it 'creates a message' do
              expect(Message).to receive(:create)

              api_event.send(:process_invoice_payment_failed, 'test-guid', 12_345, 'sub-guid', 'inv-guid')
            end

            it 'calls #mark_past_due on the subscription' do
              expect(sub).to receive(:mark_past_due)

              api_event.send(:process_invoice_payment_failed, 'test-guid', 12_345, 'sub-guid', 'inv-guid')
            end
          end
        end

        describe 'with invalid data' do
          describe 'for a User' do
            it 'calls #log_process_error' do
              allow(User).to receive(:find_by)
              allow(Subscription).to receive(:find_by).and_return(double)
              allow(Invoice).to receive(:find_by).and_return(double)
              expect(api_event).to receive(:log_process_error)

              api_event.send(:process_invoice_payment_failed, 'test-guid', 12345, 'sub-guid', 'inv-guid')
            end
          end

          describe 'for a Subscription' do
            it 'calls #log_process_error' do
              allow(User).to receive(:find_by).and_return(double)
              allow(Subscription).to receive(:find_by)
              allow(Invoice).to receive(:find_by).and_return(double)
              expect(api_event).to receive(:log_process_error)

              api_event.send(:process_invoice_payment_failed, 'test-guid', 12345, 'sub-guid', 'inv-guid')
            end
          end

          describe 'for an invoice' do
            it 'calls #log_process_error' do
              allow(User).to receive(:find_by).and_return(double)
              allow(Subscription).to receive(:find_by).and_return(double)
              allow(Invoice).to receive(:find_by)
              expect(api_event).to receive(:log_process_error)

              api_event.send(:process_invoice_payment_failed, 'test-guid', 12345, 'sub-guid', 'inv-guid')
            end
          end
        end
      end

      describe '#process_customer_subscription_deleted' do
        describe 'with valid data' do
          let(:user) { build_stubbed(:user) }
          let(:sub) { build_stubbed(:subscription) }

          before :each do
            allow(User).to receive(:find_by).and_return(user)
            allow_any_instance_of(ActiveRecord::Relation).to receive(:find_by).and_return(sub)
          end

          it 'sends a message to the logger' do
            allow(api_event).to receive(:update!)
            allow(sub).to receive(:cancel)
            expect(Rails.logger).to receive(:debug).at_least(:once)

            api_event.send(:process_customer_subscription_deleted, 'cus-guid', 'sub-guid', true)
          end

          it 'updates the record with the processing details' do
            allow(sub).to receive(:cancel)
            time = Time.zone.now
            Timecop.freeze(time) do
              expect(api_event).to receive(:update!).with({ processed: true, processed_at: time, error: false, error_message: nil })

              api_event.send(:process_customer_subscription_deleted, 'cus-guid', 'sub-guid', true)
            end
          end

          it 'calls #update_from_stripe on the subscription' do
            allow(sub).to receive(:cancel)
            allow(api_event).to receive(:update!)
            expect(sub).to receive(:update_from_stripe)

            api_event.send(:process_customer_subscription_deleted, 'cus-guid', 'sub-guid', true)
          end

          it 'calls #cancel on the subscription' do
            allow(api_event).to receive(:update!)
            expect(sub).to receive(:cancel)

            api_event.send(:process_customer_subscription_deleted, 'cus-guid', 'sub-guid', true)
          end

          it 'retruns NIL if cancel_at_period_end is TRUE' do
            allow(sub).to receive(:update_from_stripe)
            allow(sub).to receive(:cancel)
            allow(api_event).to receive(:update!)

            expect(api_event.send(:process_customer_subscription_deleted, 'cus-guid', 'sub-guid', true)).to be nil
          end

          describe 'when cancel_at_period_end is FALSE' do
            before :each do
              allow(sub).to receive(:update_from_stripe)
              allow(sub).to receive(:cancel)
              allow(api_event).to receive(:update!)
            end

            it 'creates a message' do
              expect(Message).to receive(:create)

              api_event.send(:process_customer_subscription_deleted, 'cus-guid', 'sub-guid', false)
            end
          end
        end

        describe 'with invalid data' do
          describe 'for a User' do
            it 'calls #log_process_error' do
              allow(User).to receive(:find_by)
              allow(Subscription).to receive(:find_by).and_return(double)
              expect(api_event).to receive(:log_process_error)

              api_event.send(:process_customer_subscription_deleted, 'cus-guid', 'sub-guid', true)
            end
          end

          describe 'for a Subscription' do
            it 'calls #log_process_error' do
              allow(User).to receive(:find_by).and_return(double)
              allow(Subscription).to receive(:find_by)
              expect(api_event).to receive(:log_process_error)

              api_event.send(:process_customer_subscription_deleted, 'cus-guid', 'sub-guid', true)
            end
          end
        end
      end

      describe '#process_charge_event' do
        describe 'for a valid invoice and charge' do
          let(:invoice) { build_stubbed(:invoice) }

          before :each do
            allow(Invoice).to receive(:find_by).and_return(invoice)
            allow(Charge).to receive(:create_from_stripe_data).and_return(double(id: 1))
          end

          it 'sends a message to the logger' do
            allow(api_event).to receive(:update!)
            expect(Rails.logger).to receive(:debug).at_least(:once)

            api_event.send(:process_charge_event, 'test-guid', { data: { object: 'test-object' } })
          end

          it 'updates the record with the processing details' do
            time = Time.zone.now
            Timecop.freeze(time) do
              expect(api_event).to receive(:update!).with({ processed: true, processed_at: time, error: false, error_message: nil })

              api_event.send(:process_charge_event, 'test-guid', { data: { object: 'test-object' } })
            end
          end
        end

        describe 'with invalid data' do
          describe 'for an invoice' do
            it 'calls #log_process_error' do
              allow(Invoice).to receive(:find_by).and_return(nil)
              expect(api_event).to receive(:log_process_error).with('Error creating charge. Invoice Guid: test-guid')

              api_event.send(:process_charge_event, 'test-guid', { data: { object: 'test-object' } })
            end
          end

          describe 'for a Charge' do
            it 'calls #log_process_error' do
              allow(Invoice).to receive(:find_by).and_return(double)
              allow(Charge).to receive(:create_from_stripe_data).and_return(false)
              expect(api_event).to receive(:log_process_error).with('Error creating charge. Invoice Guid: test-guid')

              api_event.send(:process_charge_event, 'test-guid', { data: { object: 'test-object' } })
            end
          end
        end
      end

      describe '#process_charge_refunded' do
        describe 'for a valid invoice and charge' do
          let(:invoice) { build_stubbed(:invoice) }

          before :each do
            allow(Invoice).to receive(:find_by).and_return(invoice)
            allow(Charge).to receive(:update_refund_data).and_return(true)
          end

          it 'updates the record with the processing details' do
            time = Time.zone.now
            Timecop.freeze(time) do
              expect(api_event).to receive(:update!).with({ processed: true, processed_at: time, error: false, error_message: nil })

              api_event.send(:process_charge_refunded, 'test-guid', { data: { object: 'test-object' } })
            end
          end
        end

        describe 'with invalid data' do
          describe 'for an invoice' do
            it 'calls #log_process_error' do
              allow(Invoice).to receive(:find_by).and_return(nil)
              allow(Charge).to receive(:update_refund_data).and_return(true)
              expect(api_event).to receive(:log_process_error).with('Error creating charge for invoice test-guid')

              api_event.send(:process_charge_refunded, 'test-guid', { data: { object: 'test-object' } })
            end
          end

          describe 'for a Charge' do
            it 'calls #log_process_error' do
              allow(Invoice).to receive(:find_by).and_return(double)
              allow(Charge).to receive(:update_refund_data)
              expect(api_event).to receive(:log_process_error).with('Error creating charge for invoice test-guid')

              api_event.send(:process_charge_refunded, 'test-guid', { data: { object: 'test-object' } })
            end
          end
        end
      end

      describe '#process_coupon_updated' do
        describe 'for a valid coupon' do
          let(:coupon) { double(deactivate: true) }

          before :each do
            allow(Coupon).to receive(:find_by).and_return(coupon)
          end

          it 'calls #deactivate on the coupon' do
            allow(api_event).to receive(:update!)
            expect(coupon).to receive(:deactivate)

            api_event.send(:process_coupon_updated, 'test-code')
          end

          it 'updates the record with the processing details' do
            time = Time.zone.now
            Timecop.freeze(time) do
              expect(api_event).to receive(:update!).with({ processed: true, processed_at: time, error: false, error_message: nil })

              api_event.send(:process_coupon_updated, 'test-code')
            end
          end
        end

        describe 'for an invalid coupon' do
          before :each do
            allow(Coupon).to receive(:find_by)
          end

          it 'calls #log_process_error if there is no matching coupon code' do
            expect(api_event).to receive(:log_process_error).with('Error updating Coupon. Code: test-code')

            api_event.send(:process_coupon_updated, 'test-code')
          end
        end
      end

      describe '#log_process_error' do
        it 'sends a message to the logger' do
          allow(api_event).to receive(:update!)
          expect(Rails.logger).to receive(:error).with('DEBUG: Stripe event processing error: Test Error')

          api_event.send(:log_process_error, 'Test Error')
        end

        it 'updates the record with error details' do
          expect(api_event).to receive(:update!).with({processed: false, error_message: 'Test Error', error: true})

          api_event.send(:log_process_error, 'Test Error')
        end
      end
    end
  end
end
