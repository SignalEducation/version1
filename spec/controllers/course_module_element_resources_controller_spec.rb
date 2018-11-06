require 'rails_helper'
require 'support/course_content'

describe CourseModuleElementResourcesController, type: :controller do

  let(:content_management_user_group) { FactoryBot.create(:content_management_user_group) }
  let(:content_management_user) { FactoryBot.create(:content_management_user, user_group_id: content_management_user_group.id) }
  let!(:content_management_user_student_access) { FactoryBot.create(:complimentary_student_access, user_id: content_management_user.id) }
  let!(:group_1) { FactoryBot.create(:group) }
  let!(:subject_course_1)  { FactoryBot.create(:active_subject_course, group_id: 1, exam_body_id: 1) }
  let!(:subject_course_2)  { FactoryBot.create(:active_subject_course, group_id: 1, computer_based: true, exam_body_id: 1) }
  include_context 'course_content'

  let!(:course_module_element_resource_1) { FactoryBot.create(:course_module_element_resource, course_module_element_id: course_module_element_2_2.id) }
  let!(:course_module_element_resource_2) { FactoryBot.create(:course_module_element_resource, course_module_element_id: course_module_element_2_2.id) }

  let!(:valid_params) { FactoryBot.attributes_for(:course_module_element_resource) }

  context 'Logged in as a content_management_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(content_management_user)
    end

    describe "GET 'index'" do
      it 'should respond OK' do
        get :index, course_module_element_id: course_module_element_2_2.id
        expect_index_success_with_model('course_module_element_resources', 2)
      end
    end

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new, course_module_element_id: course_module_element_2_2.id
        expect_new_success_with_model('course_module_element_resource')
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond OK with course_module_element_2_2' do
        get :edit, course_module_element_id: course_module_element_2_2.id, id: course_module_element_resource_1.id
        expect_edit_success_with_model('course_module_element_resource', course_module_element_resource_1.id)
      end

      # optional
      it 'should respond OK with course_module_element_2_2' do
        get :edit, course_module_element_id: course_module_element_2_2.id, id: course_module_element_resource_1.id
        expect_edit_success_with_model('course_module_element_resource', course_module_element_resource_1.id)
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, course_module_element_id: course_module_element_2_2.id, course_module_element_resource: valid_params
        expect_create_success_with_model('course_module_element_resource', edit_course_module_element_url(course_module_element_2_2.id))
      end

      it 'should report error for invalid params' do
        post :create, course_module_element_id: course_module_element_2_2.id, course_module_element_resource: {valid_params.keys.first => ''}
        expect_create_error_with_model('course_module_element_resource')
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params for course_module_element_resource_1' do
        put :update, course_module_element_id: course_module_element_2_2.id, id: course_module_element_resource_1.id, course_module_element_resource: {name: 'ABC'}
        expect_update_success_with_model('course_module_element_resource', edit_course_module_element_url(course_module_element_2_2.id))
      end

      it 'should reject invalid params' do
        put :update, course_module_element_id: course_module_element_2_2.id, id: course_module_element_resource_1.id, course_module_element_resource: {valid_params.keys.first => ''}
        expect_update_error_with_model('course_module_element_resource')
        expect(assigns(:course_module_element_resource).id).to eq(course_module_element_resource_1.id)
      end
    end

    describe "DELETE 'destroy'" do
      it 'should be OK even though dependencies exist' do
        delete :destroy, course_module_element_id: course_module_element_2_2.id, id: course_module_element_resource_1.id
        expect_archive_success_with_model('course_module_element_resource', course_module_element_resource_1.id, edit_course_module_element_url(course_module_element_2_2.id))
      end
    end

  end

end
