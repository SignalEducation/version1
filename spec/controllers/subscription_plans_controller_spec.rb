# == Schema Information
#
# Table name: subscription_plans
#
#  id                            :integer          not null, primary key
#  available_to_students         :boolean          default(FALSE), not null
#  all_you_can_eat               :boolean          default(TRUE), not null
#  payment_frequency_in_months   :integer          default(1)
#  currency_id                   :integer
#  price                         :decimal(, )
#  available_from                :date
#  available_to                  :date
#  stripe_guid                   :string
#  trial_period_in_days          :integer          default(0)
#  created_at                    :datetime
#  updated_at                    :datetime
#  name                          :string
#  subscription_plan_category_id :integer
#  livemode                      :boolean          default(FALSE)
#  paypal_guid                   :string
#  paypal_state                  :string
#  monthly_percentage_off        :integer
#  previous_plan_price           :float
#

require 'rails_helper'

describe SubscriptionPlansController, type: :controller do
  before :each do
    allow_any_instance_of(SubscriptionPlanService).to receive(:queue_async)
  end

  let(:stripe_management_user_group) { FactoryBot.create(:stripe_management_user_group) }
  let(:stripe_management_user) { FactoryBot.create(:stripe_management_user, user_group_id: stripe_management_user_group.id) }

  let!(:student_user_group ) { FactoryBot.create(:student_user_group ) }
  let!(:basic_student) { FactoryBot.create(:basic_student, user_group_id: student_user_group.id) }

  let!(:exam_body_1) { FactoryBot.create(:exam_body) }
  let!(:gbp) { create(:gbp) }
  let!(:uk) { create(:uk, currency: gbp) }

  let!(:subscription_plan_gbp_m) {
    create(
        :student_subscription_plan_m,
        currency: gbp, price: 7.50, stripe_guid: 'stripe_plan_guid_m',
        payment_frequency_in_months: 3
    )
  }
  let!(:subscription_plan_gbp_q) {
    create(
        :student_subscription_plan_q,
        currency: gbp, price: 22.50, stripe_guid: 'stripe_plan_guid_q',
        payment_frequency_in_months: 3
    )
  }
  let!(:valid_subscription) { create(:valid_subscription, user: basic_student,
                                     subscription_plan: subscription_plan_gbp_m,
                                     stripe_customer_id: basic_student.stripe_customer_id ) }

  let!(:valid_params) { FactoryBot.attributes_for(:subscription_plan, exam_body_id: exam_body_1.id,
                                                  currency_id: gbp.id, price: 220.50, stripe_guid: 'stripe_plan_guid_q',
                                                  payment_frequency_in_months: 12) }


  context 'Logged in as a stripe_management_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(stripe_management_user)
    end

    describe "GET 'index'" do
      it 'should respond OK' do
        get :index
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:index)
        expect(assigns(:subscription_plans).first.class).to eq(SubscriptionPlan)
        expect(assigns(:subscription_plans).count).to eq(2)
      end
    end

    describe "GET 'show/1'" do
      it 'should see subscription_plan_gbp_m' do
        get :show, params: { id: subscription_plan_gbp_m.id }
        expect_show_success_with_model('subscription_plan', subscription_plan_gbp_m.id)
      end

      # optional - some other object
      it 'should see subscription_plan_2' do
        get :show, params: { id: subscription_plan_gbp_q.id }
        expect_show_success_with_model('subscription_plan', subscription_plan_gbp_q.id)
      end
    end

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new
        expect_new_success_with_model('subscription_plan')
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond OK with subscription_plan_1' do
        get :edit, params: { id: subscription_plan_gbp_m.id }
        expect_edit_success_with_model('subscription_plan', subscription_plan_gbp_m.id)
      end

      # optional
      it 'should respond OK with subscription_plan_2' do
        get :edit, params: { id: subscription_plan_gbp_q.id }
        expect_edit_success_with_model('subscription_plan', subscription_plan_gbp_q.id)
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, params: { subscription_plan: valid_params }
        expect_create_success_with_model('subscription_plan', subscription_plans_url)
      end

      it 'should report error for invalid params' do
        post :create, params: { subscription_plan: {valid_params.keys.first => ''} }
        expect_create_error_with_model('subscription_plan')
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params for subscription_plan_1' do
        put :update, params: { id: subscription_plan_gbp_m.id, subscription_plan: {name: 'new-name'} }
        expect_update_success_with_model('subscription_plan', subscription_plans_url)
        expect(assigns(:subscription_plan).name).to eq('new-name')
      end

      it 'should reject invalid params' do
        put :update, params: { id: subscription_plan_gbp_m.id, subscription_plan: {name: nil} }
        expect_update_error_with_model('subscription_plan')
        expect(assigns(:subscription_plan).id).to eq(subscription_plan_gbp_m.id)
      end
    end

    describe "DELETE 'destroy'" do
      it 'should be ERROR as children exist' do
        delete :destroy, params: { id: subscription_plan_gbp_m.id }
        expect_delete_error_with_model('subscription_plan', subscription_plans_url)
      end

      it 'should be OK as no dependencies exist' do
        allow_any_instance_of(SubscriptionPlan).to(
          receive(:delete_remote_plans).and_return(true)
        )
        delete :destroy, params: { id: subscription_plan_gbp_q.id }
        expect_delete_success_with_model('subscription_plan', subscription_plans_url)
      end
    end

  end

end
