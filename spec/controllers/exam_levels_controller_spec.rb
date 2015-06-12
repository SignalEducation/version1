require 'rails_helper'
require 'support/users_and_groups_setup'

describe ExamLevelsController, type: :controller do

  include_context 'users_and_groups_setup'

  let!(:qualification) { FactoryGirl.create(:qualification) }
  let!(:exam_level_1) { FactoryGirl.create(:exam_level, qualification_id: qualification.id) }
  let!(:exam_section) { FactoryGirl.create(:exam_section, exam_level_id: exam_level_1.id) }
  let!(:exam_level_2) { FactoryGirl.create(:exam_level, qualification_id: qualification.id) }
  let!(:valid_params) { FactoryGirl.attributes_for(:exam_level, qualification_id: qualification.id) }

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
      it 'should respond ERROR not permitted' do
        get :index
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'show/1'" do
      it 'should respond ERROR not permitted' do
        get :show, id: 1
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'new'" do
      it 'should respond ERROR not permitted' do
        get :new
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond ERROR not permitted' do
        get :edit, id: 1
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should respond ERROR not permitted' do
        post :create, exam_level: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond ERROR not permitted' do
        put :update, id: 1, exam_level: valid_params
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

    describe "GET 'index'" do
      it 'should respond OK' do
        get :index
        expect_index_success_with_model('exam_levels', 2)
      end
    end

    describe "GET 'show/1'" do
      it 'should see exam_level_1' do
        get :show, id: exam_level_1.id
        expect_show_success_with_model('exam_level', exam_level_1.id)
      end

      # optional - some other object
      it 'should see exam_level_2' do
        get :show, id: exam_level_2.id
        expect_show_success_with_model('exam_level', exam_level_2.id)
      end
    end

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new
        expect_new_success_with_model('exam_level')
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond OK with exam_level_1' do
        get :edit, id: exam_level_1.id
        expect_edit_success_with_model('exam_level', exam_level_1.id)
      end

      # optional
      it 'should respond OK with exam_level_2' do
        get :edit, id: exam_level_2.id
        expect_edit_success_with_model('exam_level', exam_level_2.id)
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, exam_level: valid_params
        expect_create_success_with_model('exam_level', filtered_exam_levels_url(qualification.name_url))
      end

      it 'should report error for invalid params' do
        post :create, exam_level: {valid_params.keys.first => ''}
        expect_create_error_with_model('exam_level')
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params for exam_level_1' do
        put :update, id: exam_level_1.id, exam_level: valid_params
        expect_update_success_with_model('exam_level', filtered_exam_levels_url(qualification.name_url))
      end

      # optional
      it 'should respond OK to valid params for exam_level_2' do
        put :update, id: exam_level_2.id, exam_level: valid_params
        expect_update_success_with_model('exam_level', filtered_exam_levels_url(qualification.name_url))
        expect(assigns(:exam_level).id).to eq(exam_level_2.id)
      end

      it 'should reject invalid params' do
        put :update, id: exam_level_1.id, exam_level: {valid_params.keys.first => ''}
        expect_update_error_with_model('exam_level')
        expect(assigns(:exam_level).id).to eq(exam_level_1.id)
      end
    end

    describe "POST 'reorder'" do
      it 'should be OK with valid array' do
        post :reorder, array_of_ids: [exam_level_2.id, exam_level_1.id]
        expect_reorder_success
      end
    end

    describe "DELETE 'destroy'" do
      it 'should be ERROR as children exist' do
        delete :destroy, id: exam_level_1.id
        expect_delete_error_with_model('exam_level', exam_levels_url)
      end

      it 'should be OK as no dependencies exist' do
        delete :destroy, id: exam_level_2.id
        expect_delete_success_with_model('exam_level', exam_levels_url)
      end
    end

  end


  context 'Logged in as a corporate_student_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(corporate_student_user)
    end

    describe "GET 'index'" do
      it 'should respond ERROR not permitted' do
        get :index
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'show/1'" do
      it 'should respond ERROR not permitted' do
        get :show, id: 1
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'new'" do
      it 'should respond ERROR not permitted' do
        get :new
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond ERROR not permitted' do
        get :edit, id: 1
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should respond ERROR not permitted' do
        post :create, exam_level: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond ERROR not permitted' do
        put :update, id: 1, exam_level: valid_params
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

    describe "GET 'index'" do
      it 'should respond ERROR not permitted' do
        get :index
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'show/1'" do
      it 'should respond ERROR not permitted' do
        get :show, id: 1
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'new'" do
      it 'should respond ERROR not permitted' do
        get :new
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond ERROR not permitted' do
        get :edit, id: exam_level_1.id
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should respond ERROR not permitted' do
        post :create, exam_level: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond ERROR not permitted' do
        put :update, id: 1, exam_level: valid_params
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

    describe "GET 'index'" do
      it 'should respond ERROR not permitted' do
        get :index
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'show/1'" do
      it 'should respond ERROR not permitted' do
        get :show, id: 1
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'new'" do
      it 'should respond ERROR not permitted' do
        get :new
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond ERROR not permitted' do
        get :edit, id: 1
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should respond ERROR not permitted' do
        post :create, exam_level: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond ERROR not permitted' do
        put :update, id: 1, exam_level: valid_params
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

    describe "GET 'index'" do
      it 'should respond ERROR not permitted' do
        get :index
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'show/1'" do
      it 'should respond ERROR not permitted' do
        get :show, id: 1
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'new'" do
      it 'should respond ERROR not permitted' do
        get :new
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond ERROR not permitted' do
        get :edit, id: 1
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should respond ERROR not permitted' do
        post :create, exam_level: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond ERROR not permitted' do
        put :update, id: 1, exam_level: valid_params
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

    describe "GET 'index'" do
      it 'should respond OK' do
        get :index
        expect_index_success_with_model('exam_levels', 2)
      end
    end

    describe "GET 'show/1'" do
      it 'should see exam_level_1' do
        get :show, id: exam_level_1.id
        expect_show_success_with_model('exam_level', exam_level_1.id)
      end

      # optional - some other object
      it 'should see exam_level_2' do
        get :show, id: exam_level_2.id
        expect_show_success_with_model('exam_level', exam_level_2.id)
      end
    end

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new
        expect_new_success_with_model('exam_level')
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond OK with exam_level_1' do
        get :edit, id: exam_level_1.id
        expect_edit_success_with_model('exam_level', exam_level_1.id)
      end

      # optional
      it 'should respond OK with exam_level_2' do
        get :edit, id: exam_level_2.id
        expect_edit_success_with_model('exam_level', exam_level_2.id)
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, exam_level: valid_params
        expect_create_success_with_model('exam_level', filtered_exam_levels_url(qualification.name_url))
      end

      it 'should report error for invalid params' do
        post :create, exam_level: {valid_params.keys.first => ''}
        expect_create_error_with_model('exam_level')
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params for exam_level_1' do
        put :update, id: exam_level_1.id, exam_level: valid_params
        expect_update_success_with_model('exam_level', filtered_exam_levels_url(qualification.name_url))
      end

      # optional
      it 'should respond OK to valid params for exam_level_2' do
        put :update, id: exam_level_2.id, exam_level: valid_params
        expect_update_success_with_model('exam_level', filtered_exam_levels_url(qualification.name_url))
        expect(assigns(:exam_level).id).to eq(exam_level_2.id)
      end

      it 'should reject invalid params' do
        put :update, id: exam_level_1.id, exam_level: {valid_params.keys.first => ''}
        expect_update_error_with_model('exam_level')
        expect(assigns(:exam_level).id).to eq(exam_level_1.id)
      end
    end

    describe "POST 'reorder'" do
      it 'should be OK with valid array' do
        post :reorder, array_of_ids: [exam_level_2.id, exam_level_1.id]
        expect_reorder_success
      end
    end

    describe "DELETE 'destroy'" do
      it 'should be ERROR as children exist' do
        delete :destroy, id: exam_level_1.id
        expect_delete_error_with_model('exam_level', exam_levels_url)
      end

      it 'should be OK as no dependencies exist' do
        delete :destroy, id: exam_level_2.id
        expect_delete_success_with_model('exam_level', exam_levels_url)
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
        expect_index_success_with_model('exam_levels', 2)
      end
    end

    describe "GET 'show/1'" do
      it 'should see exam_level_1' do
        get :show, id: exam_level_1.id
        expect_show_success_with_model('exam_level', exam_level_1.id)
      end

      # optional - some other object
      it 'should see exam_level_2' do
        get :show, id: exam_level_2.id
        expect_show_success_with_model('exam_level', exam_level_2.id)
      end
    end

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new
        expect_new_success_with_model('exam_level')
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond OK with exam_level_1' do
        get :edit, id: exam_level_1.id
        expect_edit_success_with_model('exam_level', exam_level_1.id)
      end

      # optional
      it 'should respond OK with exam_level_2' do
        get :edit, id: exam_level_2.id
        expect_edit_success_with_model('exam_level', exam_level_2.id)
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, exam_level: valid_params
        expect_create_success_with_model('exam_level', filtered_exam_levels_url(qualification.name_url))
      end

      it 'should report error for invalid params' do
        post :create, exam_level: {valid_params.keys.first => ''}
        expect_create_error_with_model('exam_level')
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params for exam_level_1' do
        put :update, id: exam_level_1.id, exam_level: valid_params
        expect_update_success_with_model('exam_level', filtered_exam_levels_url(qualification.name_url))
      end

      # optional
      it 'should respond OK to valid params for exam_level_2' do
        put :update, id: exam_level_2.id, exam_level: valid_params
        expect_update_success_with_model('exam_level', filtered_exam_levels_url(qualification.name_url))
        expect(assigns(:exam_level).id).to eq(exam_level_2.id)
      end

      it 'should reject invalid params' do
        put :update, id: exam_level_1.id, exam_level: {valid_params.keys.first => ''}
        expect_update_error_with_model('exam_level')
        expect(assigns(:exam_level).id).to eq(exam_level_1.id)
      end
    end

    describe "POST 'reorder'" do
      it 'should be OK with valid array' do
        post :reorder, array_of_ids: [exam_level_2.id, exam_level_1.id]
        expect_reorder_success
      end
    end

    describe "DELETE 'destroy'" do
      it 'should be ERROR as children exist' do
        delete :destroy, id: exam_level_1.id
        expect_delete_error_with_model('exam_level', exam_levels_url)
      end

      it 'should be OK as no dependencies exist' do
        delete :destroy, id: exam_level_2.id
        expect_delete_success_with_model('exam_level', exam_levels_url)
      end
    end

  end

end
