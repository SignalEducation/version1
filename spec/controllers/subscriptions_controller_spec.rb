# == Schema Information
#
# Table name: subscriptions
#
#  id                    :integer          not null, primary key
#  user_id               :integer
#  corporate_customer_id :integer
#  subscription_plan_id  :integer
#  stripe_guid           :string
#  next_renewal_date     :date
#  complimentary         :boolean          default(FALSE), not null
#  current_status        :string
#  created_at            :datetime
#  updated_at            :datetime
#  stripe_customer_id    :string
#  stripe_customer_data  :text
#  livemode              :boolean          default(FALSE)
#

require 'rails_helper'
require 'support/users_and_groups_setup'
require 'stripe_mock'

describe SubscriptionsController, type: :controller do

  include_context 'users_and_groups_setup'

  # let!(:student_user_2) { FactoryGirl.create(:individual_student_user) }
  let(:stripe_helper) { StripeMock.create_test_helper }
  let!(:start_stripe_mock) { StripeMock.start }
  let!(:subscription_plan_1) { FactoryGirl.create(:student_subscription_plan) }
  let!(:subscription_plan_2) { FactoryGirl.create(:student_subscription_plan) }
  let!(:subscription_1) { x = FactoryGirl.create(:subscription,
                             user_id: individual_student_user.id,
                             subscription_plan_id: subscription_plan_1.id,
                             stripe_token: stripe_helper.generate_card_token)
                             individual_student_user.stripe_customer_id = x.stripe_customer_id
                             individual_student_user.save
                             x }
  let!(:subscription_2) { x = FactoryGirl.create(:subscription,
                             user_id: corporate_customer_user.id,
                             subscription_plan_id: subscription_plan_1.id,
                             stripe_token: stripe_helper.generate_card_token)
                             corporate_customer_user.stripe_customer_id = x.stripe_customer_id
                             corporate_customer_user.save
                             x }
  let!(:valid_params) { {subscription_plan_id: subscription_plan_2.id} }

  #before { StripeMock.start }
  after { StripeMock.stop }

  context 'Not logged in: ' do

    describe "POST 'create'" do
      it 'should redirect to sign_in' do
        post :create, subscription: valid_params
        expect_bounce_as_not_signed_in
      end
    end

    describe "PUT 'update/1'" do
      it 'should redirect to sign_in' do
        put :update, id: 1, subscription: valid_params
        expect_bounce_as_not_signed_in
      end
    end

    describe "DELETE 'destroy'" do
      it 'should redirect to sign_in' do
        delete :destroy, id: 1
        expect_bounce_as_not_signed_in
      end
    end

  end

  context 'Logged in as a individual_student_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(individual_student_user)
    end

    describe "POST 'create'" do
      it 'should be OK locally and on Stripe' do
        post :create, subscription: {subscription_plan_id: subscription_plan_1.id, user_id: individual_student_user.id}
        expect_create_success_with_model('subscription', account_url(anchor: 'subscriptions'))
        expect(assigns(:subscription).subscription_plan_id).to eq(subscription_plan_1.id)
      end
    end

    describe "PUT 'update/1'" do
      xit 'should be OK locally and on Stripe' do
        put :update, id: subscription_1.id, subscription: valid_params
        expect_update_success_with_model('subscription', account_url(anchor: 'subscriptions'))
        expect(assigns(:subscription).subscription_plan_id).to eq(subscription_plan_2.id)
      end

      it 'should respond with ERROR as they do not own the subscription' do
        put :update, id: subscription_2.id, subscription: valid_params
        expect(flash[:error]).to eq(I18n.t('controllers.application.you_are_not_permitted_to_do_that'))
        expect(response.status).to eq(302)
        expect(response).to redirect_to(root_url)
      end
    end

    describe "DELETE 'destroy'" do
      xit 'should respond with OK' do
        delete :destroy, id: subscription_1.id
        expect(flash[:error]).to eq(nil)
        expect(response.status).to eq(302)
        expect(response).to redirect_to(account_url(anchor: 'subscriptions'))
        expect(assigns(:subscription).current_status).to eq('canceled')
      end

      it 'should respond with ERROR as they do not own the subscription' do
        delete :destroy, id: subscription_2.id
        expect(flash[:error]).to eq(I18n.t('controllers.application.you_are_not_permitted_to_do_that'))
        expect(response.status).to eq(302)
        expect(response).to redirect_to(account_url(anchor: 'subscriptions'))
      end
    end

  end

  context 'Logged in as a tutor_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(tutor_user)
    end

    describe "POST 'create'" do
      it 'should respond ERROR not permitted' do
        post :create, subscription: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond ERROR not permitted' do
        put :update, id: 1, subscription: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "DELETE 'destroy'" do
      it 'should respond ERROR not permitted' do
        delete :destroy, id: 1
        expect_bounce_as_not_allowed
      end
    end

  end

  context 'Logged in as a corporate_student_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(corporate_student_user)
    end

    describe "POST 'create'" do
      it 'should respond ERROR not permitted' do
        post :create, subscription: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond ERROR not permitted' do
        put :update, id: 1, subscription: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "DELETE 'destroy'" do
      it 'should respond ERROR not permitted' do
        delete :destroy, id: 1
        expect_bounce_as_not_allowed
      end
    end

  end

  context 'Logged in as a corporate_customer_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(corporate_customer_user)
    end

    describe "POST 'create'" do
      it 'should be OK locally and on Stripe' do
        post :create, subscription: {subscription_plan_id: subscription_plan_1.id, user_id: corporate_customer_user.id}
        expect_create_success_with_model('subscription', account_url(anchor: 'subscriptions'))
        expect(assigns(:subscription).subscription_plan_id).to eq(subscription_plan_1.id)
      end
    end

    describe "PUT 'update/1'" do
      xit 'should be OK locally and on Stripe' do
        put :update, id: subscription_2.id, subscription: valid_params
        expect_update_success_with_model('subscription', account_url(anchor: 'subscriptions'))
        expect(assigns(:subscription).subscription_plan_id).to eq(subscription_plan_2.id)
      end

      it 'should respond with ERROR as they do not own the subscription' do
        put :update, id: subscription_1.id, subscription: valid_params
        expect(flash[:error]).to eq(I18n.t('controllers.application.you_are_not_permitted_to_do_that'))
        expect(response.status).to eq(302)
        expect(response).to redirect_to(root_url)
      end
    end

    describe "DELETE 'destroy'" do
      xit 'should respond with OK' do
        delete :destroy, id: subscription_2.id
        expect(flash[:error]).to eq(nil)
        expect(response.status).to eq(302)
        expect(response).to redirect_to(account_url(anchor: 'subscriptions'))
        expect(assigns(:subscription).current_status).to eq('canceled')
      end

      it 'should respond with ERROR as they do not own the subscription' do
        delete :destroy, id: subscription_1.id
        expect(flash[:error]).to eq(I18n.t('controllers.application.you_are_not_permitted_to_do_that'))
        expect(response.status).to eq(302)
        expect(response).to redirect_to(account_url(anchor: 'subscriptions'))
      end
    end

  end

  context 'Logged in as a blogger_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(blogger_user)
    end

    describe "POST 'create'" do
      it 'should respond ERROR not permitted' do
        post :create, subscription: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond ERROR not permitted' do
        put :update, id: 1, currency: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "DELETE 'destroy'" do
      it 'should respond ERROR not permitted' do
        delete :destroy, id: 1
        expect_bounce_as_not_allowed
      end
    end

  end

  context 'Logged in as a forum_manager_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(forum_manager_user)
    end

    describe "POST 'create'" do
      it 'should respond ERROR not permitted' do
        post :create, subscription: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond ERROR not permitted' do
        put :update, id: 1, currency: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "DELETE 'destroy'" do
      it 'should respond ERROR not permitted' do
        delete :destroy, id: 1
        expect_bounce_as_not_allowed
      end
    end

  end

  context 'Logged in as a content_manager_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(content_manager_user)
    end

    describe "POST 'create'" do
      it 'should respond ERROR not permitted' do
        post :create, subscription: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond ERROR not permitted' do
        put :update, id: 1, currency: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "DELETE 'destroy'" do
      it 'should respond ERROR not permitted' do
        delete :destroy, id: 1
        expect_bounce_as_not_allowed
      end
    end

  end

  context 'Logged in as a admin_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(admin_user)
    end

    describe "POST 'create'" do
      it 'should be OK locally and on Stripe' do
        post :create, subscription: {subscription_plan_id: subscription_plan_1.id, user_id: individual_student_user.id}
        expect_create_success_with_model('subscription', account_url(anchor: 'subscriptions'))
        expect(assigns(:subscription).subscription_plan_id).to eq(subscription_plan_1.id)
      end
    end

    describe "PUT 'update/1'" do
      xit 'should respond OK to valid params' do
        put :update, id: subscription_1.id, subscription: valid_params
        expect_update_success_with_model('subscription', account_url(anchor: 'subscriptions'))
        expect(assigns(:subscription).subscription_plan_id).to eq(subscription_plan_2.id)
      end
    end

    describe "DELETE 'destroy'" do
      xit 'should respond with OK' do
        delete :destroy, id: subscription_1.id
        expect(flash[:error]).to eq(nil)
        expect(response.status).to eq(302)
        expect(response).to redirect_to(account_url(anchor: 'subscriptions'))
        expect(assigns(:subscription).current_status).to eq('canceled')
      end
    end

  end

end
