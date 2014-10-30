<%- @user_types = %w(individual_student tutor corporate_student corporate_customer blogger forum_manager content_manager admin) -%>
require 'rails_helper'
require 'support/users_and_groups_setup'

describe <%= table_name.camelcase -%>Controller, type: :controller do

  include_context 'users_and_groups_setup'

  let!(:<%= singular_table_name -%>_1) { FactoryGirl.create(:<%= singular_table_name -%>) }
  let!(:<%= singular_table_name -%>_2) { FactoryGirl.create(:<%= singular_table_name -%>) }
  let!(:valid_params) { FactoryGirl.attributes_for(:<%= singluar_table_name -%>) }

  context 'Not logged in...' do

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

  <%- @user_types.each do |user_type| -%>
  context 'Logged in as a <%= user_type -%>_user' do

    before(:each) do
      activate_authlogic
      UserSession.create!(<%= user_type -%>_user)
    end

    describe "GET 'index'" do
      it 'should respond OK' do
        get :index
        expect_index_success_with_model('<%= singular_table_name -%>', 123)
      end
    end

    describe "GET 'show/1'" do
      it 'should see <%= singular_table_name -%>_1' do
        get :show, id: <%= singular_table_name -%>_1.id
        expect_show_success_with_model('<%= singular_table_name -%>', <%= singular_table_name -%>_1.id)
      end

      # optional - some other object
      it 'should see <%= singular_table_name -%>_2' do
        get :show, id: <%= singular_table_name -%>_2.id
        expect_show_success_with_model('<%= singular_table_name -%>', <%= singular_table_name -%>_2.id)
      end
    end

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new
        expect_new_success_with_model('<%= singular_table_name -%>')
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond OK with <%= singular_table_name -%>_1' do
        get :edit, id: individual_student_user.id
        expect_edit_success_with_model('<%= singular_table_name -%>', <%= singular_table_name -%>_1.id)
      end

    # optional
    it 'should respond OK with <%= singular_table_name -%>_2' do
        get :edit, id: admin_user.id
        expect_edit_success_with_model('<%= singular_table_name -%>', <%= singular_table_name -%>_1.id)
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, <%= singular_table_name -%>: valid_params
        expect_create_success_with_model('<= singular_table_name -%>', <%= table_name -%>_url)
      end

      it 'should report error for invalid params' do
        post :create, <%= singular_table_name -%>: {valid_params.first.key => ''}
        expect_create_error_with_model('<%= singular_table_name -%>')
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params for <%= singular_table_name -%>_1' do
        put :update, id: <%= singular_table_name -%>_1.id, <%= singular_table_name -%>: valid_params
        expect_update_success_with_model('<%= singular_table_name -%>', <%= table_name -%>_url)
      end

      # optional
      it 'should respond OK to valid params for <%= singular_table_name -%>_2' do
        put :update, id: <%= singular_table_name -%>_2.id, <%= singular_table_name -%>: valid_params
        expect_update_success_with_model('<%= singular_table_name -%>', users_url)
        expect(assigns(:<%= singular_table_name -%>).id).to eq(<%= singular_table_name -%>_2.id)
      end

      it 'should reject invalid params' do
        put :update, id: <%= singular_table_name -%>_1.id, <%= singular_table_name -%>: {valid_params.first.key => ''}
        expect_update_error_with_model('<%= singular_table_name -%>')
        expect(assigns(:<%= singular_table_name -%>).id).to eq(<%= singular_table_name -%>_2.id)
      end
    end

    describe "DELETE 'destroy'" do
      it 'should be ERROR as children exist' do
        delete :destroy, id: <%= singular_table_name -%>_1.id
        expect_delete_success_with_model('<%= singular_table_name -%>', <%= table_name -%>_url)
      end

      it 'should be OK as no dependcies exist' do
        delete :destroy, id: <%= singular_table_name -%>_2.id
        expect_delete_error_with_model('<%= singular_table_name -%>', <%= table_name -%>_url)
      end
    end


  end

  <%- end -%>

end
