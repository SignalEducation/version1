require 'rails_helper'
require 'support/users_and_groups_setup'
require 'stripe_mock'

describe SubscriptionsController, type: :controller do

  include_context 'users_and_groups_setup'

  let(:stripe_helper) { StripeMock.create_test_helper }
  let!(:start_stripe_mock) { StripeMock.start }
  let!(:subscription_plan_1) { FactoryGirl.create(:student_subscription_plan) }
  let!(:subscription_1) { FactoryGirl.create(:subscription,
                                             subscription_plan_id: subscription_plan_1.id,
                                             stripe_token: stripe_helper.generate_card_token) }
  let!(:subscription_plan_2) { FactoryGirl.create(:corporate_subscription_plan) }
  let!(:valid_params) { FactoryGirl.attributes_for(:subscription_plan) }

  #before { StripeMock.start }
  after { StripeMock.stop }

  context 'Not logged in: ' do

    describe "PUT 'update/1'" do
      it 'should redirect to sign_in' do
        put :update, id: 1, user: valid_params
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

  context 'Logged in as a tutor_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(tutor_user)
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

  context 'Logged in as a corporate_student_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(corporate_student_user)
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

  context 'Logged in as a corporate_customer_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(corporate_customer_user)
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

  context 'Logged in as a blogger_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(blogger_user)
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

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params for subscription_plan_1' do
        put :update, id: subscription_plan_1.id, subscription_plan: {name: 'new-name'}
        expect_update_success_with_model('subscription_plan', subscription_plans_url)
        expect(assigns(:subscription_plan).name).to eq('new-name')
      end

      it 'should reject invalid params' do
        put :update, id: subscription_plan_1.id, subscription_plan: {name: nil}
        expect_update_error_with_model('subscription_plan')
        expect(assigns(:subscription_plan).id).to eq(subscription_plan_1.id)
      end
    end

    describe "DELETE 'destroy'" do
      it 'should be ERROR as children exist' do
        delete :destroy, id: subscription_plan_1.id
        # expect_delete_success_with_model('subscription_plan', subscription_plans_url)
        expect_delete_error_with_model('subscription_plan', subscription_plans_url)
        plan = Stripe::Plan.retrieve(subscription_plan_1.stripe_guid)
        expect(plan.try(:deleted)).not_to eq(true)
      end

      it 'should be OK as no dependencies exist' do
        delete :destroy, id: subscription_plan_2.id
        expect_delete_success_with_model('subscription_plan', subscription_plans_url)
        expect{Stripe::Plan.retrieve(subscription_plan_2.stripe_guid)}.to raise_error { |e|
          expect(e).to be_a(Stripe::InvalidRequestError)
          expect(e.message).to eq("No such plan: #{subscription_plan_2.stripe_guid}")
        }
      end
    end

  end

end
