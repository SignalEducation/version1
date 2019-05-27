# == Schema Information
#
# Table name: course_module_element_resources
#
#  id                       :integer          not null, primary key
#  course_module_element_id :integer
#  name                     :string
#  web_url                  :string
#  created_at               :datetime
#  updated_at               :datetime
#  upload_file_name         :string
#  upload_content_type      :string
#  upload_file_size         :integer
#  upload_updated_at        :datetime
#  destroyed_at             :datetime
#

require 'rails_helper'
require 'support/course_content'

describe CourseModuleElementResourcesController, type: :controller do

  let(:content_management_user_group) { FactoryBot.create(:content_management_user_group) }
  let(:content_management_user) { FactoryBot.create(:content_management_user, user_group_id: content_management_user_group.id) }

  let!(:group) { FactoryBot.create(:group) }
  let!(:exam_body) { FactoryBot.create(:exam_body) }
  let!(:subject_course)  { FactoryBot.create(:active_subject_course, group_id: group.id, exam_body_id: exam_body.id) }
  let!(:course_section) { FactoryBot.create(:course_section,
                                            subject_course: subject_course) }
  let!(:course_module) { FactoryBot.create(:active_course_module,
                                           course_section: course_section,
                                           subject_course: subject_course) }
  let!(:course_module_element) { FactoryBot.create(:cme_video,
                                                   course_module: course_module) }
  let!(:course_module_element_resource_1) { FactoryBot.create(:course_module_element_resource, course_module_element_id: course_module_element.id) }
  let!(:course_module_element_resource_2) { FactoryBot.create(:course_module_element_resource, course_module_element_id: course_module_element.id) }

  let!(:valid_params) { FactoryBot.attributes_for(:course_module_element_resource) }

  context 'Logged in as a content_management_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(content_management_user)
    end

    describe "GET 'index'" do
      it 'should respond OK' do
        get :index, params: { course_module_element_id: course_module_element.id }
        expect_index_success_with_model('course_module_element_resources', 2)
      end
    end

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new, params: { course_module_element_id: course_module_element.id }
        expect_new_success_with_model('course_module_element_resource')
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond OK with course_module_element' do
        get :edit, params: { course_module_element_id: course_module_element.id, id: course_module_element_resource_1.id }
        expect_edit_success_with_model('course_module_element_resource', course_module_element.id)
      end

      # optional
      it 'should respond OK with course_module_element' do
        get :edit, params: { course_module_element_id: course_module_element.id, id: course_module_element_resource_1.id }
        expect_edit_success_with_model('course_module_element_resource', course_module_element_resource_1.id)
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, params: { course_module_element_id: course_module_element.id, course_module_element_resource: valid_params }
        expect_create_success_with_model('course_module_element_resource', edit_course_module_element_url(course_module_element.id))
      end
    end

    describe "POST 'create' 2" do
      it 'should report error for invalid params' do
        post :create, params: { course_module_element_id: course_module_element.id, course_module_element_resource: {valid_params.keys.first => ''} }
        expect_create_error_with_model('course_module_element_resource')
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params for course_module_element_resource_1' do
        put :update, params: { course_module_element_id: course_module_element.id, id: course_module_element_resource_1.id, course_module_element_resource: {name: 'ABC'} }
        expect_update_success_with_model('course_module_element_resource', edit_course_module_element_url(course_module_element.id))
      end

      it 'should reject invalid params' do
        put :update, params: { course_module_element_id: course_module_element.id, id: course_module_element_resource_1.id, course_module_element_resource: {valid_params.keys.first => ''} }
        expect_update_error_with_model('course_module_element_resource')
        expect(assigns(:course_module_element_resource).id).to eq(course_module_element_resource_1.id)
      end
    end

    describe "DELETE 'destroy'" do
      it 'should be OK even though dependencies exist' do
        delete :destroy, params: { course_module_element_id: course_module_element.id, id: course_module_element_resource_1.id }
        expect_archive_success_with_model('course_module_element_resource', course_module_element_resource_1.id, edit_course_module_element_url(course_module_element.id))
      end
    end

  end

end
