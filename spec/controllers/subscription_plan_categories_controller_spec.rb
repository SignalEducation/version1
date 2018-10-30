# == Schema Information
#
# Table name: subscription_plan_categories
#
#  id                   :integer          not null, primary key
#  name                 :string
#  available_from       :datetime
#  available_to         :datetime
#  guid                 :string
#  created_at           :datetime
#  updated_at           :datetime
#  trial_period_in_days :integer
#

require 'rails_helper'

describe SubscriptionPlanCategoriesController, type: :controller do

  let(:stripe_management_user_group) { FactoryBot.create(:stripe_management_user_group) }
  let(:stripe_management_user) { FactoryBot.create(:stripe_management_user, user_group_id: stripe_management_user_group.id) }
  let!(:stripe_management_student_access) { FactoryBot.create(:complimentary_student_access, user_id: stripe_management_user.id) }

  let!(:subscription_plan_category_1) { FactoryBot.create(:subscription_plan_category) }
  let!(:subscription_plan) { FactoryBot.create(:subscription_plan,
                subscription_plan_category_id: subscription_plan_category_1.id) }
  let!(:subscription_plan_category_2) { FactoryBot.create(:subscription_plan_category) }
  let!(:valid_params) { FactoryBot.attributes_for(:subscription_plan_category) }

  context 'Logged in as a stripe_management_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(stripe_management_user)
    end

    describe "GET 'index'" do
      it 'should respond OK' do
        get :index
        expect_index_success_with_model('subscription_plan_categories', 2)
      end
    end

    describe "GET 'show/1'" do
      it 'should see subscription_plan_category_1' do
        get :show, id: subscription_plan_category_1.id
        expect_show_success_with_model('subscription_plan_category', subscription_plan_category_1.id)
      end

      it 'should see subscription_plan_category_2' do
        get :show, id: subscription_plan_category_2.id
        expect_show_success_with_model('subscription_plan_category', subscription_plan_category_2.id)
      end
    end

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new
        expect_new_success_with_model('subscription_plan_category')
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond OK with subscription_plan_category_1' do
        get :edit, id: subscription_plan_category_1.id
        expect_edit_success_with_model('subscription_plan_category', subscription_plan_category_1.id)
      end

      it 'should respond OK with subscription_plan_category_2' do
        get :edit, id: subscription_plan_category_2.id
        expect_edit_success_with_model('subscription_plan_category', subscription_plan_category_2.id)
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, subscription_plan_category: valid_params
        expect_create_success_with_model('subscription_plan_category', subscription_plan_categories_url)
      end

      it 'should report error for invalid params' do
        post :create, subscription_plan_category: {valid_params.keys.first => ''}
        expect_create_error_with_model('subscription_plan_category')
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params for subscription_plan_category_1' do
        put :update, id: subscription_plan_category_1.id, subscription_plan_category: valid_params
        expect_update_success_with_model('subscription_plan_category', subscription_plan_categories_url)
      end

      it 'should respond OK to valid params for subscription_plan_category_2' do
        put :update, id: subscription_plan_category_2.id, subscription_plan_category: valid_params
        expect_update_success_with_model('subscription_plan_category', subscription_plan_categories_url)
        expect(assigns(:subscription_plan_category).id).to eq(subscription_plan_category_2.id)
      end

      it 'should reject invalid params' do
        put :update, id: subscription_plan_category_1.id, subscription_plan_category: {valid_params.keys.first => ''}
        expect_update_error_with_model('subscription_plan_category')
        expect(assigns(:subscription_plan_category).id).to eq(subscription_plan_category_1.id)
      end
    end

    describe "DELETE 'destroy'" do
      it 'should be ERROR as children exist' do
        delete :destroy, id: subscription_plan_category_1.id
        expect_delete_error_with_model('subscription_plan_category', subscription_plan_categories_url)
      end

      it 'should be OK as no dependencies exist' do
        delete :destroy, id: subscription_plan_category_2.id
        expect_delete_success_with_model('subscription_plan_category', subscription_plan_categories_url)
      end
    end
  end

end
