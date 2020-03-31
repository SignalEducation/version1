require 'rails_helper'

describe Api::StripeWebhooksController, type: :controller do

  before :each do
    allow_any_instance_of(StripePlanService).to receive(:create_plan)
    allow_any_instance_of(PaypalPlansService).to receive(:create_plan)
    allow_any_instance_of(StripeApiEvent).to receive(:get_data_from_stripe).and_return(true)
  end

  let!(:gbp) { create(:currency) }
  let!(:uk) { create(:uk, currency: gbp) }
  let!(:uk_vat_code) { create(:vat_code, country: uk) }
  let!(:uk_vat_rate) { create(:vat_rate, vat_code: uk_vat_code) }
  let!(:subscription_plan_gbp_m) { create(:student_subscription_plan_m,
                                                     currency: gbp, price: 7.50, stripe_guid: 'stripe_plan_guid_m') }
  let!(:subscription_plan_gbp_q) { create(:student_subscription_plan_q,
                                                     currency: gbp, price: 22.50, stripe_guid: 'stripe_plan_guid_q') }
  let!(:subscription_plan_gbp_y) { create(:student_subscription_plan_y,
                                                     currency: gbp, price: 87.99, stripe_guid: 'stripe_plan_guid_y') }
  let!(:student_user_group ) { create(:student_user_group ) }
  let!(:basic_student) { create(:basic_student,
                                                 user_group: student_user_group) }

  let!(:valid_subscription_student) { create(:basic_student,
                                                        user_group: student_user_group) }

  let!(:valid_subscription) { create(:valid_subscription, user: valid_subscription_student,
                                                subscription_plan: subscription_plan_gbp_m,
                                                stripe_customer_id: valid_subscription_student.stripe_customer_id ) }
  let!(:default_card) { create(:subscription_payment_card, user: valid_subscription_student,
                                          is_default_card: true, stripe_card_guid: 'guid_222',
                                          status: 'card-live' ) }
  let!(:invoice) {
    create(
      :invoice,
      user: valid_subscription_student,
      subscription: valid_subscription,
      total: 99,
      currency: gbp,
      vat_rate: uk_vat_rate,
      stripe_guid: 'in_1APVed2eZvKYlo2CP6dsoJTo'
    )
  }

  let!(:charge) { create(:charge, user: valid_subscription_student,
                                    subscription: valid_subscription, invoice: invoice,
                                    subscription_payment_card: default_card, currency: gbp,
                                    stripe_guid: 'ch_21334nj453h', amount: 100, status: 'succeeded') }

  let(:coupon) { create(:coupon, name: '25.5% off', code: '25_5OFF', duration: 'repeating') }
  let(:inv_created_body) { File.read(Rails.root.join('spec/fixtures/stripe/invoice_created.json')).to_s }

  describe "POST 'create'" do
    it 'calls the #process_json before_action' do
      expect(subject).to receive(:process_json)
      post :create, body: '{}', format: :json
    end

    it 'returns a :no_content header response if it succeeds' do
      post :create, body: '{}', format: :json
      expect(response.status).to eq(204)
    end

    it 'returns a :not_found header response if it does not succeed (flags on Stripe)' do
      allow(subject).to receive(:record_webhook).and_raise(StandardError)
      post :create, body: inv_created_body, format: :json
      expect(response.status).to eq(404)
    end

    describe 'for valid request body' do
      it 'calls #record_webhook if it is a valid webhook' do
        expect(subject).to receive(:record_webhook)

        post :create, body: inv_created_body, format: :json
      end
    end

    describe 'for and invalid request body' do
      it 'does not call #record_webhook if it is not a valid webhook body' do
        expect(subject).not_to receive(:record_webhook)

        post :create, body: '{}', format: :json
      end
    end

    describe '#record_webhook' do
      it 'schedules the StripeApiProcessorWorker' do
        allow(StripeApiEvent).to receive(:processing_delay).and_return(10.seconds)
        expect(StripeApiProcessorWorker).to receive(:perform_at).with(10.seconds, 'evt_1234566', '2019-05-16', account_url)

        subject.send(:record_webhook, { 'id' => 'evt_1234566', 'api_version' => '2019-05-16' })
      end
    end
  end
end
