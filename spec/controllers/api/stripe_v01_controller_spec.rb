require 'rails_helper'

describe Api::StripeV01Controller, type: :controller do

  #let!(:start_stripe_mock) { StripeMock.start }
  #let(:stripe_helper) { StripeMock.create_test_helper }

  let!(:usd) { FactoryGirl.create(:usd) }
  let!(:student) { FactoryGirl.create(:individual_student_user) }
  let!(:subscription_plan_m) { FactoryGirl.create(:student_subscription_plan_m) }
  let!(:subscription_plan_q) { FactoryGirl.create(:student_subscription_plan_q) }
  let!(:subscription_plan_y) { FactoryGirl.create(:student_subscription_plan_y) }
  let!(:card_details_1) { {number: '4242424242424242', cvc: '123', exp_month: '12', exp_year: '2019'} }
  let!(:card_details_2) { {number: '4242424242424242', cvc: '123', exp_month: '11', exp_year: '2019'} }
  let!(:card_token_1)   { Stripe::Token.create(card: card_details_1) }
  let!(:card_token_2)   { Stripe::Token.create(card: card_details_2) }
  let!(:subscription_1) { FactoryGirl.create(:subscription, user_id: student.id,
                          subscription_plan_id: subscription_plan_m.id,
                          stripe_token: card_token_1.id) }

  let!(:invoice_created_event) { x = JSON.parse(StripeMock.mock_webhook_event('invoice.created',
                          currency: usd.iso_code.downcase,
                          subscription: subscription_1.stripe_guid,
                          customer: student.stripe_customer_id).to_json, {symbolize_names: true})
                          x[:data][:object][:lines][:data][0][:plan][:id] = subscription_plan.stripe_guid
                          x }
  let(:invoice_updated) { StripeMock.mock_webhook_event('invoice.updated').to_hash }


  describe "POST 'create'" do
    describe 'preliminary functionality: ' do
      xit 'returns 204 when called with no payload (to support Stripe Pings)' do
        expect(Rails.logger).to receive(:error)
        post :create
        expect(response.status).to eq(204)
      end

      xit 'logs an error if invalid JSON is received' do
        expect(Rails.logger).to receive(:error)
        post :create, event: {id: '123'}
        expect(response.status).to eq(404)
      end
    end

    describe 'dealing with payload data:' do
      describe 'invoice' do
        xit 'created' do
          post :create, invoice_created_event
          expect(StripeApiEvent.all.count).to eq(1)
          puts '=' * 100
          puts StripeApiEvent.first.inspect
          puts '=' * 100

          expect(Invoice.all.count).to eq(1)
        end

        xit 'updated' do
          StripeMock.start
          post :create, invoice_updated
          expect(StripeApiEvent.all.count).to eq(1)
          expect(Invoice.all.count).to eq(1)
        end
      end

      describe 'cards.' do
        xit 'create' do

        end
      end
    end

  end

end
