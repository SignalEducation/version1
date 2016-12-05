# == Schema Information
#
# Table name: subject_course_categories
#
#  id           :integer          not null, primary key
#  name         :string
#  payment_type :string
#  active       :boolean          default(FALSE)
#  subdomain    :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

require 'rails_helper'
require 'support/users_and_groups_setup'

describe SubjectCourseCategoriesController, type: :controller do

  include_context 'users_and_groups_setup'

  let!(:product_course_category) { FactoryGirl.create(:product_course_category) }
  let!(:subscription_course_category) { FactoryGirl.create(:subscription_course_category) }
  let!(:corporate_course_category) { FactoryGirl.create(:corporate_course_category) }
  let!(:valid_params) { FactoryGirl.attributes_for(:subject_course_category) }

  context 'Not logged in: ' do

    describe "GET 'index'" do
      it 'should redirect to sign_in' do
        get :index
        expect_bounce_as_not_signed_in
      end
    end

    describe "GET 'show/1'" do
      it 'should redirect to sign_in' do
        get :show, id: 1
        expect_bounce_as_not_signed_in
      end
    end

    describe "GET 'new'" do
      it 'should redirect to sign_in' do
        get :new
        expect_bounce_as_not_signed_in
      end
    end

    describe "GET 'edit/1'" do
      it 'should redirect to sign_in' do
        get :edit, id: 1
        expect_bounce_as_not_signed_in
      end
    end

    describe "POST 'create'" do
      it 'should redirect to sign_in' do
        post :create, user: valid_params
        expect_bounce_as_not_signed_in
      end
    end

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

    describe "GET 'index'" do
      it 'should respond OK' do
        get :index
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'show/1'" do
      it 'should see subscription_course_category' do
        get :show, id: subscription_course_category.id
        expect_bounce_as_not_allowed

      end

      # optional - some other object
      it 'should see product_course_category' do
        get :show, id: product_course_category.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond OK with subscription_course_category' do
        get :edit, id: subscription_course_category.id
        subscription_course_category
      end

      # optional
      it 'should respond OK with product_course_category' do
        get :edit, id: product_course_category.id
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, subject_course_category: valid_params
        subscription_course_category
      end

      it 'should report error for invalid params' do
        post :create, subject_course_category: {valid_params.keys.first => ''}
        subscription_course_category
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params for subscription_course_category' do
        put :update, id: subscription_course_category.id, subject_course_category: valid_params
        subscription_course_category
      end

      # optional
      it 'should respond OK to valid params for product_course_category' do
        put :update, id: product_course_category.id, subject_course_category: valid_params
        subscription_course_category
      end

      it 'should reject invalid params' do
        put :update, id: subscription_course_category.id, subject_course_category: {valid_params.keys.first => ''}
        subscription_course_category
      end
    end


    describe "DELETE 'destroy'" do
      it 'should be ERROR as children exist' do
        delete :destroy, id: subscription_course_category.id
        subscription_course_category
      end

      it 'should be OK as no dependencies exist' do
        delete :destroy, id: product_course_category.id
        subscription_course_category
      end
    end

  end

  context 'Logged in as a complimentary_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(comp_user)
    end

    describe "GET 'index'" do
      it 'should respond OK' do
        get :index
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'show/1'" do
      it 'should see subscription_course_category' do
        get :show, id: subscription_course_category.id
        expect_bounce_as_not_allowed

      end

      # optional - some other object
      it 'should see product_course_category' do
        get :show, id: product_course_category.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond OK with subscription_course_category' do
        get :edit, id: subscription_course_category.id
        subscription_course_category
      end

      # optional
      it 'should respond OK with product_course_category' do
        get :edit, id: product_course_category.id
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, subject_course_category: valid_params
        subscription_course_category
      end

      it 'should report error for invalid params' do
        post :create, subject_course_category: {valid_params.keys.first => ''}
        subscription_course_category
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params for subscription_course_category' do
        put :update, id: subscription_course_category.id, subject_course_category: valid_params
        subscription_course_category
      end

      # optional
      it 'should respond OK to valid params for product_course_category' do
        put :update, id: product_course_category.id, subject_course_category: valid_params
        subscription_course_category
      end

      it 'should reject invalid params' do
        put :update, id: subscription_course_category.id, subject_course_category: {valid_params.keys.first => ''}
        subscription_course_category
      end
    end


    describe "DELETE 'destroy'" do
      it 'should be ERROR as children exist' do
        delete :destroy, id: subscription_course_category.id
        subscription_course_category
      end

      it 'should be OK as no dependencies exist' do
        delete :destroy, id: product_course_category.id
        subscription_course_category
      end
    end

  end

  context 'Logged in as a tutor_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(tutor_user)
    end

    describe "GET 'index'" do
      it 'should respond OK' do
        get :index
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'show/1'" do
      it 'should see subscription_course_category' do
        get :show, id: subscription_course_category.id
        expect_bounce_as_not_allowed
      end

      # optional - some other object
      it 'should see product_course_category' do
        get :show, id: product_course_category.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond OK with subscription_course_category' do
        get :edit, id: subscription_course_category.id
        expect_bounce_as_not_allowed
      end

      # optional
      it 'should respond OK with product_course_category' do
        get :edit, id: product_course_category.id
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, subject_course_category: valid_params
        expect_bounce_as_not_allowed
      end

      it 'should report error for invalid params' do
        post :create, subject_course_category: {valid_params.keys.first => ''}
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params for subscription_course_category' do
        put :update, id: subscription_course_category.id, subject_course_category: valid_params
        expect_bounce_as_not_allowed
      end

      # optional
      it 'should respond OK to valid params for product_course_category' do
        put :update, id: product_course_category.id, subject_course_category: valid_params
        expect_bounce_as_not_allowed
      end

      it 'should reject invalid params' do
        put :update, id: subscription_course_category.id, subject_course_category: {valid_params.keys.first => ''}
        expect_bounce_as_not_allowed
      end
    end


    describe "DELETE 'destroy'" do
      it 'should be ERROR as children exist' do
        delete :destroy, id: subscription_course_category.id
        expect_bounce_as_not_allowed
      end

      it 'should be OK as no dependencies exist' do
        delete :destroy, id: product_course_category.id
        expect_bounce_as_not_allowed
      end
    end

  end

  context 'Logged in as a corporate_student_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(corporate_student_user)
    end

    describe "GET 'index'" do
      it 'should respond OK' do
        get :index
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'show/1'" do
      it 'should see subscription_course_category' do
        get :show, id: subscription_course_category.id
        expect_bounce_as_not_allowed
      end

      # optional - some other object
      it 'should see product_course_category' do
        get :show, id: product_course_category.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond OK with subscription_course_category' do
        get :edit, id: subscription_course_category.id
        expect_bounce_as_not_allowed
      end

      # optional
      it 'should respond OK with product_course_category' do
        get :edit, id: product_course_category.id
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, subject_course_category: valid_params
        expect_bounce_as_not_allowed
      end

      it 'should report error for invalid params' do
        post :create, subject_course_category: {valid_params.keys.first => ''}
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params for subscription_course_category' do
        put :update, id: subscription_course_category.id, subject_course_category: valid_params
        expect_bounce_as_not_allowed
      end

      # optional
      it 'should respond OK to valid params for product_course_category' do
        put :update, id: product_course_category.id, subject_course_category: valid_params
        expect_bounce_as_not_allowed
      end

      it 'should reject invalid params' do
        put :update, id: subscription_course_category.id, subject_course_category: {valid_params.keys.first => ''}
        expect_bounce_as_not_allowed
      end
    end


    describe "DELETE 'destroy'" do
      it 'should be ERROR as children exist' do
        delete :destroy, id: subscription_course_category.id
        expect_bounce_as_not_allowed
      end

      it 'should be OK as no dependencies exist' do
        delete :destroy, id: product_course_category.id
        expect_bounce_as_not_allowed
      end
    end

  end

  context 'Logged in as a corporate_customer_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(corporate_customer_user)
    end

    describe "GET 'index'" do
      it 'should respond OK' do
        get :index
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'show/1'" do
      it 'should see subscription_course_category' do
        get :show, id: subscription_course_category.id
        expect_bounce_as_not_allowed
      end

      # optional - some other object
      it 'should see product_course_category' do
        get :show, id: product_course_category.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond OK with subscription_course_category' do
        get :edit, id: subscription_course_category.id
        expect_bounce_as_not_allowed
      end

      # optional
      it 'should respond OK with product_course_category' do
        get :edit, id: product_course_category.id
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, subject_course_category: valid_params
        expect_bounce_as_not_allowed
      end

      it 'should report error for invalid params' do
        post :create, subject_course_category: {valid_params.keys.first => ''}
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params for subscription_course_category' do
        put :update, id: subscription_course_category.id, subject_course_category: valid_params
        expect_bounce_as_not_allowed
      end

      # optional
      it 'should respond OK to valid params for product_course_category' do
        put :update, id: product_course_category.id, subject_course_category: valid_params
        expect_bounce_as_not_allowed
      end

      it 'should reject invalid params' do
        put :update, id: subscription_course_category.id, subject_course_category: {valid_params.keys.first => ''}
        expect_bounce_as_not_allowed
      end
    end


    describe "DELETE 'destroy'" do
      it 'should be ERROR as children exist' do
        delete :destroy, id: subscription_course_category.id
        expect_bounce_as_not_allowed
      end

      it 'should be OK as no dependencies exist' do
        delete :destroy, id: product_course_category.id
        expect_bounce_as_not_allowed
      end
    end

  end

  context 'Logged in as a blogger_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(blogger_user)
    end

    describe "GET 'index'" do
      it 'should respond OK' do
        get :index
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'show/1'" do
      it 'should see subscription_course_category' do
        get :show, id: subscription_course_category.id
        expect_bounce_as_not_allowed
      end

      # optional - some other object
      it 'should see product_course_category' do
        get :show, id: product_course_category.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond OK with subscription_course_category' do
        get :edit, id: subscription_course_category.id
        expect_bounce_as_not_allowed
      end

      # optional
      it 'should respond OK with product_course_category' do
        get :edit, id: product_course_category.id
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, subject_course_category: valid_params
        expect_bounce_as_not_allowed
      end

      it 'should report error for invalid params' do
        post :create, subject_course_category: {valid_params.keys.first => ''}
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params for subscription_course_category' do
        put :update, id: subscription_course_category.id, subject_course_category: valid_params
        expect_bounce_as_not_allowed
      end

      # optional
      it 'should respond OK to valid params for product_course_category' do
        put :update, id: product_course_category.id, subject_course_category: valid_params
        expect_bounce_as_not_allowed
      end

      it 'should reject invalid params' do
        put :update, id: subscription_course_category.id, subject_course_category: {valid_params.keys.first => ''}
        expect_bounce_as_not_allowed
      end
    end


    describe "DELETE 'destroy'" do
      it 'should be ERROR as children exist' do
        delete :destroy, id: subscription_course_category.id
        expect_bounce_as_not_allowed
      end

      it 'should be OK as no dependencies exist' do
        delete :destroy, id: product_course_category.id
        expect_bounce_as_not_allowed
      end
    end

  end

  context 'Logged in as a content_manager_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(content_manager_user)
    end

    describe "GET 'index'" do
      it 'should respond OK' do
        get :index
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'show/1'" do
      it 'should see subscription_course_category' do
        get :show, id: subscription_course_category.id
        expect_bounce_as_not_allowed
      end

      # optional - some other object
      it 'should see product_course_category' do
        get :show, id: product_course_category.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond OK with subscription_course_category' do
        get :edit, id: subscription_course_category.id
        expect_bounce_as_not_allowed
      end

      # optional
      it 'should respond OK with product_course_category' do
        get :edit, id: product_course_category.id
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, subject_course_category: valid_params
        expect_bounce_as_not_allowed
      end

      it 'should report error for invalid params' do
        post :create, subject_course_category: {valid_params.keys.first => ''}
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params for subscription_course_category' do
        put :update, id: subscription_course_category.id, subject_course_category: valid_params
        expect_bounce_as_not_allowed
      end

      # optional
      it 'should respond OK to valid params for product_course_category' do
        put :update, id: product_course_category.id, subject_course_category: valid_params
        expect_bounce_as_not_allowed
      end

      it 'should reject invalid params' do
        put :update, id: subscription_course_category.id, subject_course_category: {valid_params.keys.first => ''}
        expect_bounce_as_not_allowed
      end
    end


    describe "DELETE 'destroy'" do
      it 'should be ERROR as children exist' do
        delete :destroy, id: subscription_course_category.id
        expect_bounce_as_not_allowed
      end

      it 'should be OK as no dependencies exist' do
        delete :destroy, id: product_course_category.id
        expect_bounce_as_not_allowed
      end
    end

  end

  context 'Logged in as a admin_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(admin_user)
    end

    describe "GET 'index'" do
      it 'should respond OK' do
        get :index
        expect_index_success_with_model('subject_course_categories', 3)
      end
    end

    describe "GET 'show/1'" do
      it 'should see subscription_course_category' do
        get :show, id: subscription_course_category.id
        expect_show_success_with_model('subject_course_category', subscription_course_category.id)
      end

      # optional - some other object
      it 'should see product_course_category' do
        get :show, id: product_course_category.id
        expect_show_success_with_model('subject_course_category', product_course_category.id)
      end
    end

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new
        expect_new_success_with_model('subject_course_category')
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond OK with subscription_course_category' do
        get :edit, id: subscription_course_category.id
        expect_edit_success_with_model('subject_course_category', subscription_course_category.id)
      end

      # optional
      it 'should respond OK with product_course_category' do
        get :edit, id: product_course_category.id
        expect_edit_success_with_model('subject_course_category', product_course_category.id)
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, subject_course_category: valid_params
        expect_create_success_with_model('subject_course_category', subject_course_categories_url)
      end

      it 'should report error for invalid params' do
        post :create, subject_course_category: {valid_params.keys.first => ''}
        expect_create_error_with_model('subject_course_category')
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params for subscription_course_category' do
        put :update, id: subscription_course_category.id, subject_course_category: valid_params
        expect_update_success_with_model('subject_course_category', subject_course_categories_url)
      end

      # optional
      it 'should respond OK to valid params for product_course_category' do
        put :update, id: product_course_category.id, subject_course_category: valid_params
        expect_update_success_with_model('subject_course_category', subject_course_categories_url)
        expect(assigns(:subject_course_category).id).to eq(product_course_category.id)
      end

      it 'should reject invalid params' do
        put :update, id: subscription_course_category.id, subject_course_category: {valid_params.keys.first => ''}
        expect_update_error_with_model('subject_course_category')
        expect(assigns(:subject_course_category).id).to eq(subscription_course_category.id)
      end
    end


    describe "DELETE 'destroy'" do
      it 'should be ERROR as children exist' do
        delete :destroy, id: subscription_course_category.id
        expect_delete_error_with_model('subject_course_category', subject_course_categories_url)
      end

      it 'should be OK as no dependencies exist' do
        delete :destroy, id: product_course_category.id
        expect_delete_error_with_model('subject_course_category', subject_course_categories_url)
      end
    end

  end

end
