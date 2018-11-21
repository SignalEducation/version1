require 'rails_helper'

describe PaypalService, type: :service do

  describe '#create_billing_agreement' do
    let(:subscription) { build_stubbed(:subscription) }
    let(:auth_response) { File.read('./spec/fixtures/paypal/auth_request_response.rb').to_json }
    let(:billing_agreement) { File.read('./spec/fixtures/paypal/billing_agreement_response.rb').to_json }

    before :each do
      stub_request(:post, "https://api.sandbox.paypal.com/v1/oauth2/token").
        with(
          body: {"grant_type"=>"client_credentials"},
          headers: {
            'Accept'=>'*/*',
            'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'Authorization'=>'Basic UkFORE9NX0NMSUVOVF9JRDpSQU5ET01fQ0xJRU5UX1NFQ1JFVA==',
            'Content-Type'=>'application/x-www-form-urlencoded',
            'User-Agent'=>'PayPalSDK/PayPal-Ruby-SDK 1.7.2 (paypal-sdk-core 1.7.2; ruby 2.2.9p480-x86_64-darwin17;OpenSSL 1.0.2p  14 Aug 2018)'
          }
        ).to_return(
          status: 200,
          body: auth_response, 
          headers: {}
        )
      stub_request(:post, "https://api.sandbox.paypal.com/v1/payments/billing-agreements/").
        to_return(
          status: 200,
          body: billing_agreement, 
          headers: {}
        )
    end

    it 'calls the correct paypal REST API method' do
      # expect_any_instance_of(Agreement).to receive(:create).and_return(true)

      subject.send(:create_billing_agreement, subscription, subscription.user)
    end
  end

  describe '#suspend_billing_agreement' do
    it 'calls the correct paypal REST API method'
  end

  describe '#reactivate_billing_agreement' do
    it 'calls the correct paypal REST API method'
  end

  describe '#cancel_billing_agreement' do
    it 'calls the correct paypal REST API method'
  end

  # PRIVATE METHODS ############################################################

  describe '#agreement_attributes' do
    let(:subscription) { build_stubbed(:subscription) }

    it 'returns the correct hash' do
      expect(subject.send(:agreement_attributes, subscription, subscription.user))
        .to eq (
          {
            name: subscription.subscription_plan.name,
            description: subscription.subscription_plan.description.gsub("\n", ""),
            start_date: (Time.zone.now + subscription.subscription_plan.payment_frequency_in_months.months).iso8601,
            payer: {
              payment_method: "paypal",
              payer_info: {
                email: subscription.user.email,
                first_name: subscription.user.first_name,
                last_name: subscription.user.last_name
              }
            },
            override_merchant_preferences: {
              setup_fee: {
                value: subscription.subscription_plan.price.to_s,
                currency: subscription.subscription_plan.currency.iso_code
              },
              return_url: "https://staging.learnsignal.com/en/subscriptions/#{subscription.id}/execute?payment_processor=paypal",
              cancel_url: "https://staging.learnsignal.com/en/new_subscription?flash=It+seems+you+cancelled+your+subscription+on+Paypal.+Still+want+to+upgrade%3F"
            },
            plan: {
              id: subscription.subscription_plan.paypal_guid
            }
          }
        )
    end
  end

  describe '#plan_attributes' do
    let(:plan) { build_stubbed(:subscription_plan) }

    it 'returns the correct hash' do
      expect(subject.send(:plan_attributes, plan))
        .to eq (
          {
            name: "LearnSignal #{plan.name}",
            description: plan.description,
            type: "INFINITE",
            payment_definitions: [
              {
                name: "Regular payment definition",
                type: "REGULAR",
                frequency: "MONTH",
                frequency_interval: plan.payment_frequency_in_months.to_s,
                amount: {
                  value: plan.price.to_s,
                  currency: plan.currency.iso_code
                },
                cycles: "0",
              }
            ],
            merchant_preferences: {
              setup_fee: {
                value: "0",
                currency: plan.currency.iso_code
              },
              return_url: "https://example.com",
              cancel_url: "https://example.com/cancel",
              auto_bill_amount: "YES",
              initial_fail_amount_action: "CANCEL",
              max_fail_attempts: "4"
            }
          }
        )
    end
  end

  # describe '#patch' do
  #   let(:)
  # end

  # def patch(op, update_attributes)
  #   patch = Patch.new
  #   patch.op = op
  #   patch.path = "/"
  #   patch.value = update_attributes
  #   patch
  # end  

  describe 'async methods that communicate with PayPal / Stripe' do
    before :each do
      allow_any_instance_of(SubscriptionPlanService).to receive(:queue_async).and_return(true)
    end

    describe '#update_subscription_plan' do
      let(:plan) { create(:subscription_plan, paypal_state: 'CREATED') }
      let(:paypal_plan) { OpenStruct.new({ id: "PLAN-fdsfsdf43245423532", state: 'ACTIVE' }) }

      it 'updates the paypal_state of a subscription' do
        expect(plan.paypal_state).to eq 'CREATED'
        expect(plan.paypal_guid).to be_nil

        subject.send(:update_subscription_plan, plan, paypal_plan)

        expect(plan.paypal_state).to eq 'ACTIVE'
        expect(plan.paypal_state).not_to be_nil
      end
    end

    describe '#update_subscription_plan_state' do
      let(:plan) { create(:subscription_plan, paypal_state: 'CREATED') }

      it 'updates the paypal_state of a subscription' do
        expect(plan.paypal_state).to eq 'CREATED'

        subject.send(:update_subscription_plan_state, plan, 'ACTIVE')

        expect(plan.paypal_state).to eq 'ACTIVE'
      end
    end
  end

  describe '#learnsignal_host' do
    describe 'non-production ENVs' do
      it 'returns the correct host' do
        expect(subject.send(:learnsignal_host))
          .to eq 'https://staging.learnsignal.com'
      end
    end

    describe 'production ENV' do
      before :each do
        Rails.env.stub(:production? => true)
      end

      it 'returns the correct host' do
        expect(subject.send(:learnsignal_host)).to eq 'https://learnsignal.com'
      end
    end
  end
end