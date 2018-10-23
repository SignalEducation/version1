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
#

require 'rails_helper'

describe SubscriptionPlansController, type: :controller do

  let(:stripe_management_user_group) { FactoryBot.create(:stripe_management_user_group) }
  let(:stripe_management_user) { FactoryBot.create(:stripe_management_user, user_group_id: stripe_management_user_group.id) }
  let!(:stripe_management_student_access) { FactoryBot.create(:complimentary_student_access, user_id: stripe_management_user.id) }
  let!(:student_user_group ) { FactoryBot.create(:student_user_group ) }
  let!(:student_user) { FactoryBot.create(:student_user, user_group_id: student_user_group.id) }
  let!(:student_access) { FactoryBot.create(:valid_free_trial_student_access, user_id: student_user.id) }

  let!(:subscription_plan_1) { FactoryBot.create(:student_subscription_plan) }
  let!(:subscription_plan_2) { FactoryBot.create(:student_subscription_plan) }
  let!(:stripe_student_user) { FactoryBot.create(:student_user,
                                                  stripe_customer_id: (Stripe::Customer.create({email: student_user.email})).id) }

  let!(:subscription_1) { FactoryBot.create(:subscription,
                          subscription_plan_id: subscription_plan_1.id,
                          user_id: stripe_student_user.id,
                          stripe_token: stripe_helper.generate_card_token) }

  let!(:valid_params) { FactoryBot.attributes_for(:subscription_plan) }


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
      it 'should see subscription_plan_1' do
        get :show, id: subscription_plan_1.id
        expect_show_success_with_model('subscription_plan', subscription_plan_1.id)
      end

      # optional - some other object
      it 'should see subscription_plan_2' do
        get :show, id: subscription_plan_2.id
        expect_show_success_with_model('subscription_plan', subscription_plan_2.id)
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
        get :edit, id: subscription_plan_1.id
        expect_edit_success_with_model('subscription_plan', subscription_plan_1.id)
      end

      # optional
      it 'should respond OK with subscription_plan_2' do
        get :edit, id: subscription_plan_2.id
        expect_edit_success_with_model('subscription_plan', subscription_plan_2.id)
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, subscription_plan: valid_params
        expect_create_success_with_model('subscription_plan', subscription_plans_url)
      end

      it 'should report error for invalid params' do
        post :create, subscription_plan: {valid_params.keys.first => ''}
        expect_create_error_with_model('subscription_plan')
      end
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
