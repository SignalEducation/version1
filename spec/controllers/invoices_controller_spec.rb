require 'rails_helper'
require 'support/users_and_groups_setup'

describe InvoicesController, type: :controller do

  include_context 'users_and_groups_setup'

  # todo: Try to create children for individual_student_user_invoice
  let!(:individual_student_user_invoice) { FactoryGirl.create(:invoice,
                                  user_id: individual_student_user.id) }
  let!(:corporate_student_user_invoice) { FactoryGirl.create(:invoice,
                                  user_id: corporate_student_user.id) }
  let!(:tutor_user_invoice) { FactoryGirl.create(:invoice,
                                  user_id: tutor_user.id) }
  let!(:content_manager_user_invoice) { FactoryGirl.create(:invoice,
                                  user_id: content_manager_user.id) }
  let!(:blogger_user_invoice) { FactoryGirl.create(:invoice,
                                  user_id: blogger_user.id) }
  let!(:corporate_customer_user_invoice) { FactoryGirl.create(:invoice,
                                  user_id: corporate_customer_user.id) }
  let!(:forum_manager_user_invoice) { FactoryGirl.create(:invoice,
                                  user_id: forum_manager_user.id) }
  let!(:admin_user_invoice) { FactoryGirl.create(:invoice,
                                  user_id: admin_user.id) }
  let!(:valid_params) { FactoryGirl.attributes_for(:invoice) }

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
        expect_index_success_with_model('invoices', 1)
      end
    end

    describe "GET 'show/1'" do
      it 'should see invoice' do
        get :show, id: individual_student_user_invoice.id
        expect_show_success_with_model('invoice', individual_student_user_invoice.id)
      end

      # optional - some other object
      it 'should return ERROR and redirect' do
        get :show, id: corporate_student_user_invoice.id
        expect_error_bounce(invoices_url)
      end
    end

    describe "GET 'new'" do
      it 'should respond ERROR not allowed' do
        get :new
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond ERROR not allowed' do
        get :edit, id: 1
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should report ERROR as not allowed' do
        post :create, invoice: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond ERROR as not allowed' do
        put :update, id: 1, invoice: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "DELETE 'destroy'" do
      it 'should be ERROR as children exist' do
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

    describe "GET 'index'" do
      it 'should respond OK' do
        get :index
        expect_index_success_with_model('invoices', 1)
      end
    end

    describe "GET 'show/1'" do
      it 'should see invoice' do
        get :show, id: tutor_user_invoice.id
        expect_show_success_with_model('invoice', tutor_user_invoice.id)
      end

      # optional - some other object
      it 'should return ERROR and redirect' do
        get :show, id: individual_student_user_invoice.id
        expect_error_bounce(invoices_url)
      end
    end

    describe "GET 'new'" do
      it 'should respond ERROR not allowed' do
        get :new
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond ERROR not allowed' do
        get :edit, id: 1
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should report ERROR as not allowed' do
        post :create, invoice: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond ERROR as not allowed' do
        put :update, id: 1, invoice: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "DELETE 'destroy'" do
      it 'should be ERROR as children exist' do
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

    describe "GET 'index'" do
      it 'should respond OK' do
        get :index
        expect_index_success_with_model('invoices', 1)
      end
    end

    describe "GET 'show/1'" do
      it 'should see invoice' do
        get :show, id: corporate_student_user_invoice.id
        expect_show_success_with_model('invoice', corporate_student_user_invoice.id)
      end

      # optional - some other object
      it 'should return ERROR and redirect' do
        get :show, id: individual_student_user_invoice.id
        expect_error_bounce(invoices_url)
      end
    end

    describe "GET 'new'" do
      it 'should respond ERROR not allowed' do
        get :new
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond ERROR not allowed' do
        get :edit, id: 1
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should report ERROR as not allowed' do
        post :create, invoice: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond ERROR as not allowed' do
        put :update, id: 1, invoice: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "DELETE 'destroy'" do
      it 'should be ERROR as children exist' do
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

    describe "GET 'index'" do
      it 'should respond OK' do
        get :index
        expect_index_success_with_model('invoices', 1)
      end
    end

    describe "GET 'show/1'" do
      it 'should see invoice' do
        get :show, id: corporate_customer_user_invoice.id
        expect_show_success_with_model('invoice', corporate_customer_user_invoice.id)
      end

      # optional - some other object
      it 'should return ERROR and redirect' do
        get :show, id: individual_student_user_invoice.id
        expect_error_bounce(invoices_url)
      end
    end

    describe "GET 'new'" do
      it 'should respond ERROR not allowed' do
        get :new
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond ERROR not allowed' do
        get :edit, id: 1
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should report ERROR as not allowed' do
        post :create, invoice: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond ERROR as not allowed' do
        put :update, id: 1, invoice: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "DELETE 'destroy'" do
      it 'should be ERROR as children exist' do
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

    describe "GET 'index'" do
      it 'should respond OK' do
        get :index
        expect_index_success_with_model('invoices', 1)
      end
    end

    describe "GET 'show/1'" do
      it 'should see invoice' do
        get :show, id: blogger_user_invoice.id
        expect_show_success_with_model('invoice', blogger_user_invoice.id)
      end

      # optional - some other object
      it 'should return ERROR and redirect' do
        get :show, id: corporate_student_user_invoice.id
        expect_error_bounce(invoices_url)
      end
    end

    describe "GET 'new'" do
      it 'should respond ERROR not allowed' do
        get :new
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond ERROR not allowed' do
        get :edit, id: 1
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should report ERROR as not allowed' do
        post :create, invoice: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond ERROR as not allowed' do
        put :update, id: 1, invoice: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "DELETE 'destroy'" do
      it 'should be ERROR as children exist' do
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

    describe "GET 'index'" do
      it 'should respond OK' do
        get :index
        expect_index_success_with_model('invoices', 1)
      end
    end

    describe "GET 'show/1'" do
      it 'should see invoice' do
        get :show, id: forum_manager_user_invoice.id
        expect_show_success_with_model('invoice', forum_manager_user_invoice.id)
      end

      # optional - some other object
      it 'should return ERROR and redirect' do
        get :show, id: corporate_student_user_invoice.id
        expect_error_bounce(invoices_url)
      end
    end

    describe "GET 'new'" do
      it 'should respond ERROR not allowed' do
        get :new
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond ERROR not allowed' do
        get :edit, id: 1
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should report ERROR as not allowed' do
        post :create, invoice: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond ERROR as not allowed' do
        put :update, id: 1, invoice: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "DELETE 'destroy'" do
      it 'should be ERROR as children exist' do
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

    describe "GET 'index'" do
      it 'should respond OK' do
        get :index
        expect_index_success_with_model('invoices', 1)
      end
    end

    describe "GET 'show/1'" do
      it 'should see invoice' do
        get :show, id: content_manager_user_invoice.id
        expect_show_success_with_model('invoice', content_manager_user_invoice.id)
      end

      # optional - some other object
      it 'should return ERROR and redirect' do
        get :show, id: corporate_student_user_invoice.id
        expect_error_bounce(invoices_url)
      end
    end

    describe "GET 'new'" do
      it 'should respond ERROR not allowed' do
        get :new
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond ERROR not allowed' do
        get :edit, id: 1
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should report ERROR as not allowed' do
        post :create, invoice: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond ERROR as not allowed' do
        put :update, id: 1, invoice: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "DELETE 'destroy'" do
      it 'should be ERROR as children exist' do
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

    describe "GET 'index'" do
      it 'should respond OK' do
        get :index
        expect_index_success_with_model('invoices', 8)
      end
    end

    describe "GET 'show/1'" do
      it 'should see invoice_1' do
        get :show, id: individual_student_user_invoice.id
        expect_show_success_with_model('invoice', individual_student_user_invoice.id)
      end

      # optional - some other object
      it 'should see invoice_2' do
        get :show, id: admin_user_invoice.id
        expect_show_success_with_model('invoice', admin_user_invoice.id)
      end
    end

    describe "GET 'new'" do
      it 'should respond ERROR as not allowed' do
        get :new
        expect_error_bounce(invoices_url)
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond ERROR as not allowed' do
        get :edit, id: admin_user_invoice.id
        expect_error_bounce(invoices_url)
      end
    end

    describe "POST 'create'" do
      it 'should respond ERROR as not allowed' do
        post :create, invoice: valid_params
        expect_error_bounce(invoices_url)
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond ERROR as not allowed' do
        put :update, id: admin_user_invoice.id, invoice: valid_params
        expect_error_bounce(invoices_url)
      end
    end

    describe "DELETE 'destroy'" do
      it 'should be ERROR as children exist' do
        delete :destroy, id: admin_user_invoice.id
        expect_error_bounce(invoices_url)
      end
    end

  end

end
