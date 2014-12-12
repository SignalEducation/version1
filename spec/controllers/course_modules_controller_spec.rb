require 'rails_helper'
require 'support/users_and_groups_setup'

describe CourseModulesController, type: :controller do

  include_context 'users_and_groups_setup'

  let!(:qualification) {FactoryGirl.create(:qualification) }
  let!(:exam_level) {FactoryGirl.create(:exam_level, qualification_id: qualification.id) }
  let!(:course_module_1) { FactoryGirl.create(:course_module, qualification_id: qualification.id, exam_level_id: exam_level.id) }
  let!(:course_module_element) { FactoryGirl.create(:course_module_element, course_module_id: course_module_1.id) }
  let!(:course_module_2) { FactoryGirl.create(:course_module, qualification_id: qualification.id, exam_level_id: exam_level.id) }
  let!(:valid_params) { FactoryGirl.attributes_for(:course_module) }

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

    describe "POST 'reorder'" do
      it 'should be OK with valid_array' do
        post :create, array_of_ids: [1,2]
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
        post :create, course_module: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond ERROR not permitted' do
        put :update, id: 1, course_module: valid_params
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
        expect(assigns[:qualifications].first.class).to eq(Qualification)
        expect(response).to render_template(:index)
        expect(flash[:error]).to eq(nil)
      end
    end

    describe "GET 'show/1'" do
      it 'should see course_module_1' do
        get :show, id: nil, course_module_url: course_module_1.name_url,
            qualification_url: qualification.name_url
        expect_show_success_with_model('course_module', course_module_1.id)
      end

      # optional - some other object
      it 'should see course_module_2' do
        get :show, id: course_module_2.id
        expect(response).to redirect_to(course_modules_url)
        expect(flash[:error]).to eq(I18n.t('controllers.course_modules.show.cant_find'))
      end
    end

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new
        expect_new_success_with_model('course_module')
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond OK with course_module_1' do
        get :edit, id: course_module_1.id
        expect_edit_success_with_model('course_module', course_module_1.id)
      end

      # optional
      it 'should respond OK with course_module_2' do
        get :edit, id: course_module_2.id
        expect_edit_success_with_model('course_module', course_module_2.id)
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, course_module: valid_params
        expect_create_success_with_model('course_module', course_modules_url)
      end

      it 'should report error for invalid params' do
        post :create, course_module: {valid_params.keys.first => ''}
        expect_create_error_with_model('course_module')
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params for course_module_1' do
        put :update, id: course_module_1.id, course_module: {name: 'ABC'}
        expect(flash[:success]).to eq(I18n.t('controllers.course_modules.update.flash.success'))
        expect(flash[:error]).to eq(nil)
        expect(assigns(:course_module).class).to eq(CourseModule)
        expect(response).to redirect_to(course_modules_for_qualification_exam_level_exam_section_and_name_url(course_module_1.exam_level.qualification.name_url, course_module_1.exam_level.name_url, course_module_1.exam_section.try(:name_url) || 'all', course_module_1.name_url))
      end

      # optional
      it 'should respond OK to valid params for course_module_2' do
        put :update, id: course_module_2.id, course_module: {name: 'ABC'}
        expect(flash[:success]).to eq(I18n.t('controllers.course_modules.update.flash.success'))
        expect(flash[:error]).to eq(nil)
        expect(assigns(:course_module).class).to eq(CourseModule)
        expect(response).to redirect_to(course_modules_for_qualification_exam_level_exam_section_and_name_url(course_module_2.exam_level.qualification.name_url, course_module_2.exam_level.name_url, course_module_2.exam_section.try(:name_url) || 'all', course_module_2.name_url))
      end

      it 'should reject invalid params' do
        put :update, id: course_module_1.id, course_module: {valid_params.keys.first => ''}
        expect_update_error_with_model('course_module')
        expect(assigns(:course_module).id).to eq(course_module_1.id)
      end
    end

    describe "POST 'reorder'" do
      it 'should be OK with valid_array' do
        post :reorder, array_of_ids: [course_module_2.id, course_module_1.id]
        expect_reorder_success
      end
    end

    describe "DELETE 'destroy'" do
      it 'should be ERROR as children exist' do
        delete :destroy, id: course_module_1.id
        expect_delete_error_with_model('course_module', course_modules_url)
      end

      it 'should be OK as no dependencies exist' do
        delete :destroy, id: course_module_2.id
        expect_delete_success_with_model('course_module', course_modules_url)
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
        post :create, course_module: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond ERROR not permitted' do
        put :update, id: 1, course_module: valid_params
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
        get :edit, id: 1
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should respond ERROR not permitted' do
        post :create, course_module: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond ERROR not permitted' do
        put :update, id: 1, course_module: valid_params
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
        post :create, course_module: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond ERROR not permitted' do
        put :update, id: 1, course_module: valid_params
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
        post :create, course_module: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond ERROR not permitted' do
        put :update, id: 1, course_module: valid_params
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
        post :create, course_module: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond ERROR not permitted' do
        put :update, id: 1, course_module: valid_params
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

    describe "GET 'index'" do
      it 'should respond OK' do
        get :index
        expect(assigns[:qualifications].first.class).to eq(Qualification)
        expect(response).to render_template(:index)
        expect(flash[:error]).to eq(nil)
      end
    end

    describe "GET 'show/1'" do
      it 'should see course_module_1' do
        get :show, id: nil, course_module_url: course_module_1.name_url,
            qualification_url: qualification.name_url
        expect_show_success_with_model('course_module', course_module_1.id)
      end

      # optional - some other object
      it 'should see course_module_2' do
        get :show, id: course_module_2.id
        expect(response).to redirect_to(course_modules_url)
        expect(flash[:error]).to eq(I18n.t('controllers.course_modules.show.cant_find'))
      end
    end

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new
        expect_new_success_with_model('course_module')
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond OK with course_module_1' do
        get :edit, id: course_module_1.id
        expect_edit_success_with_model('course_module', course_module_1.id)
      end

      # optional
      it 'should respond OK with course_module_2' do
        get :edit, id: course_module_2.id
        expect_edit_success_with_model('course_module', course_module_2.id)
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, course_module: valid_params
        expect_create_success_with_model('course_module', course_modules_url)
      end

      it 'should report error for invalid params' do
        post :create, course_module: {valid_params.keys.first => ''}
        expect_create_error_with_model('course_module')
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params for course_module_1' do
        put :update, id: course_module_1.id, course_module: {name: 'ABC'}
        expect(flash[:success]).to eq(I18n.t('controllers.course_modules.update.flash.success'))
        expect(flash[:error]).to eq(nil)
        expect(assigns(:course_module).class).to eq(CourseModule)
        expect(response).to redirect_to(course_modules_for_qualification_exam_level_exam_section_and_name_url(course_module_1.exam_level.qualification.name_url, course_module_1.exam_level.name_url, course_module_1.exam_section.try(:name_url) || 'all', course_module_1.name_url))
      end

      # optional
      it 'should respond OK to valid params for course_module_2' do
        put :update, id: course_module_2.id, course_module: {name: 'ABC'}
        expect(flash[:success]).to eq(I18n.t('controllers.course_modules.update.flash.success'))
        expect(flash[:error]).to eq(nil)
        expect(assigns(:course_module).class).to eq(CourseModule)
        expect(response).to redirect_to(course_modules_for_qualification_exam_level_exam_section_and_name_url(course_module_2.exam_level.qualification.name_url, course_module_2.exam_level.name_url, course_module_2.exam_section.try(:name_url) || 'all', course_module_2.name_url))
      end

      it 'should reject invalid params' do
        put :update, id: course_module_1.id, course_module: {valid_params.keys.first => ''}
        expect_update_error_with_model('course_module')
        expect(assigns(:course_module).id).to eq(course_module_1.id)
      end
    end

    describe "POST 'reorder'" do
      it 'should be OK with valid_array' do
        post :reorder, array_of_ids: [course_module_2.id, course_module_1.id]
        expect_reorder_success
      end
    end

    describe "DELETE 'destroy'" do
      it 'should be ERROR as children exist' do
        delete :destroy, id: course_module_1.id
        expect_delete_error_with_model('course_module', course_modules_url)
      end

      it 'should be OK as no dependencies exist' do
        delete :destroy, id: course_module_2.id
        expect_delete_success_with_model('course_module', course_modules_url)
      end
    end

  end

end
