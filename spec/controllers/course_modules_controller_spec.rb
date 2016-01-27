# == Schema Information
#
# Table name: course_modules
#
#  id                        :integer          not null, primary key
#  name                      :string
#  name_url                  :string
#  description               :text
#  tutor_id                  :integer
#  sorting_order             :integer
#  estimated_time_in_seconds :integer
#  active                    :boolean          default(FALSE), not null
#  created_at                :datetime
#  updated_at                :datetime
#  cme_count                 :integer          default(0)
#  seo_description           :string
#  seo_no_index              :boolean          default(FALSE)
#  destroyed_at              :datetime
#  number_of_questions       :integer          default(0)
#  subject_course_id         :integer
#  video_duration            :float            default(0.0)
#  video_count               :integer          default(0)
#  quiz_count                :integer          default(0)
#

require 'rails_helper'
require 'support/users_and_groups_setup'

describe CourseModulesController, type: :controller do

  include_context 'users_and_groups_setup'

  let!(:subject_course) {FactoryGirl.create(:active_subject_course) }
  let!(:course_module_1) { FactoryGirl.create(:course_module, subject_course_id: subject_course.id) }
  let!(:course_module_element) { FactoryGirl.create(:course_module_element, course_module_id: course_module_1.id) }
  let!(:course_module_2) { FactoryGirl.create(:course_module, subject_course_id: subject_course.id) }
  let!(:valid_params) { FactoryGirl.attributes_for(:course_module, subject_course_id: subject_course.id) }

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
        expect_create_success_with_model('course_module', subject.course_module_special_link(assigns(:course_module)))
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
        expect(response).to redirect_to(subject_course_url(course_module_1.subject_course))
      end

      # optional
      it 'should respond OK to valid params for course_module_2' do
        put :update, id: course_module_2.id, course_module: {name: 'ABC'}
        expect(flash[:success]).to eq(I18n.t('controllers.course_modules.update.flash.success'))
        expect(flash[:error]).to eq(nil)
        expect(assigns(:course_module).class).to eq(CourseModule)
        expect(response).to redirect_to(subject_course_url(course_module_1.subject_course))      end

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
      it 'should be OK even though dependencies exist' do
        delete :destroy, id: course_module_1.id
        expect_archive_success_with_model('course_module', course_module_1.id, subject_course_url(course_module_1.subject_course))
      end

      it 'should be OK as no dependencies exist' do
        delete :destroy, id: course_module_2.id
        expect_archive_success_with_model('course_module', course_module_2.id, subject_course_url(course_module_2.subject_course))
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
        expect_create_success_with_model('course_module', subject.course_module_special_link(assigns(:course_module)))
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
        expect(response).to redirect_to(subject_course_url(course_module_1.subject_course))
      end

      # optional
      it 'should respond OK to valid params for course_module_2' do
        put :update, id: course_module_2.id, course_module: {name: 'ABC'}
        expect(flash[:success]).to eq(I18n.t('controllers.course_modules.update.flash.success'))
        expect(flash[:error]).to eq(nil)
        expect(assigns(:course_module).class).to eq(CourseModule)
        expect(response).to redirect_to(subject_course_url(course_module_2.subject_course))
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
      it 'should be OK even though dependencies exist' do
        delete :destroy, id: course_module_1.id
        expect_archive_success_with_model('course_module', course_module_1.id, subject_course_url(course_module_1.subject_course))
      end

      it 'should be OK as no dependencies exist' do
        delete :destroy, id: course_module_2.id
        expect_archive_success_with_model('course_module', course_module_2.id, subject_course_url(course_module_2.subject_course))
      end
    end

  end

  context 'Logged in as a admin_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(admin_user)
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
        expect_create_success_with_model('course_module', subject.course_module_special_link(assigns(:course_module)))
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
        expect(response).to redirect_to(subject_course_url(course_module_1.subject_course))
      end

      # optional
      it 'should respond OK to valid params for course_module_2' do
        put :update, id: course_module_2.id, course_module: {name: 'ABC'}
        expect(flash[:success]).to eq(I18n.t('controllers.course_modules.update.flash.success'))
        expect(flash[:error]).to eq(nil)
        expect(assigns(:course_module).class).to eq(CourseModule)
        expect(response).to redirect_to(subject_course_url(course_module_2.subject_course))
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
      it 'should be OK even though dependencies exist' do
        delete :destroy, id: course_module_1.id
        expect_archive_success_with_model('course_module', course_module_1.id, subject_course_url(course_module_1.subject_course))
      end

      it 'should be OK as no dependencies exist' do
        delete :destroy, id: course_module_2.id
        expect_archive_success_with_model('course_module', course_module_2.id, subject_course_url(course_module_2.subject_course))
      end
    end

  end

end
