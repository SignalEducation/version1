# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SubscriptionManagementController, type: :controller do
  before :each do
    allow_any_instance_of(SubscriptionPlanService).to receive(:queue_async)
  end

  let!(:exam_body_1)                   { create(:exam_body) }
  let!(:gbp)                           { create(:gbp) }
  let!(:uk)                            { create(:uk, currency: gbp) }
  let!(:uk_vat_code)                   { create(:vat_code, country: uk) }
  let!(:uk_vat_rate)                   { create(:vat_rate, vat_code: uk_vat_code) }
  let!(:subscription_plan_gbp_m)       { create(:student_subscription_plan_m, currency_id: gbp.id, price: 7.50, stripe_guid: 'stripe_plan_guid_m') }
  let(:user_management_user_group)     { create(:user_management_user_group) }
  let(:user_management_user)           { create(:user_management_user, user_group_id: user_management_user_group.id) }
  let!(:student_user_group )           { create(:student_user_group) }
  let!(:valid_subscription_student)    { create(:basic_student, user_group_id: student_user_group.id) }
  let!(:valid_subscription)            { create(:valid_subscription, user_id: valid_subscription_student.id, subscription_plan_id: subscription_plan_gbp_m.id, stripe_customer_id: valid_subscription_student.stripe_customer_id) }
  let!(:invoice)                       { create(:invoice, user: valid_subscription_student, subscription_id: valid_subscription.id, issued_at: Time.zone.now, vat_rate: uk_vat_rate) }
  let!(:canceled_pending_student)      { create(:basic_student, user_group_id: student_user_group.id) }
  let!(:canceled_pending_subscription) { create(:canceled_pending_subscription, user_id: canceled_pending_student.id, subscription_plan_id: subscription_plan_gbp_m.id, stripe_customer_id: canceled_pending_student.stripe_customer_id) }
  let!(:canceled_student)              { create(:basic_student, user_group_id: student_user_group.id) }
  let!(:canceled_subscription)         { create(:canceled_subscription, user_id: canceled_student.id, subscription_plan_id: subscription_plan_gbp_m.id, stripe_customer_id: canceled_student.stripe_customer_id) }
  let!(:default_card)                  { create(:subscription_payment_card, user_id: canceled_student.id, is_default_card: true, stripe_card_guid: 'guid_222', status: 'card-live') }
  let!(:charge)                        { create(:charge, user: valid_subscription_student, subscription: valid_subscription, invoice: invoice, subscription_payment_card: default_card, stripe_api_event_id: nil) }
  let(:cancellation_params)            { { cancellation_reason: 'reason', cancellation_note: 'note', cancelled_by_id: valid_subscription_student.id, cancelling_subscription: true } }

  context 'Logged in as a user_management_user: ' do
    before(:each) do
      activate_authlogic
      UserSession.create!(user_management_user)
    end

    describe "GET 'show'" do
      it 'should see valid_subscription' do
        get :show, params: { id: valid_subscription.id }
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:show)
      end
    end

    describe "GET 'invoice'" do
      it 'should see valid invoice' do
        get :invoice, params: { subscription_management_id: valid_subscription.id, invoice_id: invoice.id }
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:invoice)
      end
    end

    describe "GET 'pdf_invoice'" do
      context 'valid invoice' do
        it 'should see a pdf invoice' do
          get :pdf_invoice, format: :pdf, params: { subscription_management_id: valid_subscription.id, invoice_id: invoice.id }
          expect(response.status).to eq(200)
          expect(response.content_type).to eq('application/pdf')
        end
      end

      context 'invalid invoice' do
        it 'should be redirecrt to user profile' do
          get :pdf_invoice, format: :pdf, params: { subscription_management_id: valid_subscription.id, invoice_id: (invoice.id + 2) }
          expect(response).to be_redirect
          expect(response).to have_http_status(:redirect)
          expect(response).to redirect_to(users_path)
        end
      end
    end

    describe "GET 'charge'" do
      it 'should see valid charge' do
        get :charge, params: { subscription_management_id: valid_subscription.id, invoice_id: invoice.id, id: charge.id }
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:charge)
      end
    end

    describe "GET 'cancellation'" do
      it 'should see cancellation page' do
        get :cancellation, params: { subscription_management_id: valid_subscription.id, invoice_id: invoice.id }
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template('subscription_management/admin_new')
      end
    end

    describe "POST 'cancel_subscription'" do
      context 'successful cancellation' do
        it 'Cancel a subscription' do
          expect_any_instance_of(SubscriptionService).to receive(:cancel_subscription).and_return(true)
          post :cancel_subscription, params: { subscription_management_id: valid_subscription.id, subscription: cancellation_params, type: :standard }

          expect(response).to be_redirect
          expect(response).to have_http_status(:redirect)
          expect(response).to redirect_to(subscription_management_path(valid_subscription))
          expect(flash[:success]).to eq(I18n.t('controllers.subscription_management.cancel.flash.success'))
          expect(flash[:error]).to be_nil
        end

        it 'Immediate Cancel a subscription' do
          expect_any_instance_of(SubscriptionService).to receive(:cancel_subscription_immediately).and_return(true)
          post :cancel_subscription, params: { subscription_management_id: valid_subscription.id, subscription: cancellation_params, type: :immediate }

          expect(response).to be_redirect
          expect(response).to have_http_status(:redirect)
          expect(response).to redirect_to(subscription_management_path(valid_subscription))
          expect(flash[:success]).to eq(I18n.t('controllers.subscription_management.cancel.flash.success'))
          expect(flash[:error]).to be_nil
        end
      end

      context 'unsuccessful cancellation' do
        it 'Error in cancel a subscription' do
          post :cancel_subscription, params: { subscription_management_id: valid_subscription.id, subscription: cancellation_params }

          expect(response).to be_redirect
          expect(response).to have_http_status(:redirect)
          expect(response).to redirect_to(subscription_management_path(valid_subscription))
          expect(flash[:success]).to be_nil
          expect(flash[:error]).to eq(I18n.t('controllers.subscription_management.cancel.flash.error'))
        end

        it 'Error raised in cancel a subscription' do
          expect_any_instance_of(Subscription).to(receive(:update).and_raise(Learnsignal::SubscriptionError.new('error')))
          post :cancel_subscription, params: { subscription_management_id: valid_subscription.id, subscription: cancellation_params }

          expect(response).to be_redirect
          expect(response).to have_http_status(:redirect)
          expect(response).to redirect_to(subscription_management_path(valid_subscription))
          expect(flash[:success]).to be_nil
          expect(flash[:error]).to eq(I18n.t('controllers.subscription_management.cancel.flash.error'))
        end
      end
    end

    describe "POST 'un_cancel_subscription'" do
      context 'successful uncancel' do
        it 'Uncancel a subscription' do
          expect_any_instance_of(Subscription).to receive(:un_cancel).and_return(true)
          post :un_cancel_subscription, params: { subscription_management_id: canceled_pending_subscription.id }

          expect(response).to be_redirect
          expect(response).to have_http_status(:redirect)
          expect(response).to redirect_to(subscription_management_path(canceled_pending_subscription))
          expect(flash[:success]).to eq(I18n.t('controllers.subscription_management.un_cancel_subscription.flash.success'))
          expect(flash[:error]).to be_nil
        end
      end

      context 'unsuccessful uncancel' do
        it 'Error in uncancel a subscription' do
          expect_any_instance_of(Subscription).to receive(:un_cancel).and_return(false)
          post :un_cancel_subscription, params: { subscription_management_id: canceled_pending_subscription.id }

          expect(response).to be_redirect
          expect(response).to have_http_status(:redirect)
          expect(response).to redirect_to(subscription_management_path(canceled_pending_subscription))
          expect(flash[:success]).to be_nil
          expect(flash[:error]).to eq(I18n.t('controllers.subscription_management.un_cancel_subscription.flash.error'))
        end
      end

      context 'unsuccessful uncancel' do
        it 'Error in uncancel a subscription - status reason' do
          post :un_cancel_subscription, params: { subscription_management_id: valid_subscription.id }

          expect(response).to be_redirect
          expect(response).to have_http_status(:redirect)
          expect(response).to redirect_to(subscription_management_path(valid_subscription))
          expect(flash[:success]).to be_nil
          expect(flash[:error]).to eq(I18n.t('controllers.subscription_management.un_cancel_subscription.flash.not_pending_sub'))
        end
      end
    end

    describe "POST 'reactivate_subscription'" do
      context 'successful reactivate a subscription' do
        it 'reactivate a subscription' do
          expect_any_instance_of(Subscription).to receive(:reactivate_canceled).and_return(true)
          post :reactivate_subscription, params: { subscription_management_id: valid_subscription.id }

          expect(response).to be_redirect
          expect(response).to have_http_status(:redirect)
          expect(response).to redirect_to(subscription_management_path(valid_subscription))
          expect(flash[:success]).to eq(I18n.t('controllers.subscription_management.reactivate_canceled.flash.success'))
          expect(flash[:error]).to be_nil
        end
      end

      context 'unsuccessful cancellation' do
        it 'Error in uncancel a subscription' do
          expect_any_instance_of(Subscription).to receive(:reactivate_canceled).and_return(false)
          post :reactivate_subscription, params: { subscription_management_id: valid_subscription.id }

          expect(response).to be_redirect
          expect(response).to have_http_status(:redirect)
          expect(response).to redirect_to(subscription_management_path(valid_subscription))
          expect(flash[:success]).to be_nil
          expect(flash[:error]).to eq(I18n.t('controllers.subscription_management.reactivate_canceled.flash.error') << '[]')
        end
      end
    end
  end
end
