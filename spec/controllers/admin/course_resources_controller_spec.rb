# == Schema Information
#
# Table name: course_resources
#
#  id                       :integer          not null, primary key
#  name                     :string
#  course_id        :integer
#  description              :text
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  file_upload_file_name    :string
#  file_upload_content_type :string
#  file_upload_file_size    :integer
#  file_upload_updated_at   :datetime
#  external_url             :string
#  active                   :boolean          default(FALSE)
#  sorting_order            :integer
#  available_on_trial       :boolean          default(FALSE)
#

require 'rails_helper'

describe Admin::CourseResourcesController, type: :controller do

  let(:content_management_user_group) { FactoryBot.create(:content_management_user_group) }
  let(:content_management_user) { FactoryBot.create(:content_management_user, user_group_id: content_management_user_group.id) }
  let!(:exam_body_1) { FactoryBot.create(:exam_body) }
  let!(:group_1) { FactoryBot.create(:group) }
  let!(:course_1)  { FactoryBot.create(:active_course,
                                               group_id: group_1.id,
                                               exam_body_id: exam_body_1.id) }

  let!(:course_resource_1) { FactoryBot.create(:course_resource, course_id: course_1.id) }
  let!(:course_resource_2) { FactoryBot.create(:course_resource, course_id: course_1.id) }
  let!(:valid_params) { FactoryBot.attributes_for(:course_resource, course_id: course_1.id) }

  #TODO - review this controller with Courses controller. Is this needed?
  #TODO - the new, create and index are not used - versions in courses controller
  context 'Logged in as a content_management_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(content_management_user)
    end

    describe "GET 'index'" do
      it 'should respond OK' do
        get :index
        expect_index_success_with_model('course_resources', 2)
      end
    end

    describe "GET 'show/1'" do
      it 'should see course_resource_1' do
        get :show, params: { id: course_resource_1.id }
        expect_show_success_with_model('course_resource', course_resource_1.id)
      end

      # optional - some other object
      it 'should see course_resource_2' do
        get :show, params: { id: course_resource_2.id }
        expect_show_success_with_model('course_resource', course_resource_2.id)
      end
    end

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new
        expect_new_success_with_model('course_resource')
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond OK with course_resource_1' do
        get :edit, params: { id: course_resource_1.id }
        expect_edit_success_with_model('course_resource', course_resource_1.id)
      end

      # optional
      it 'should respond OK with course_resource_2' do
        get :edit, params: { id: course_resource_2.id }
        expect_edit_success_with_model('course_resource', course_resource_2.id)
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, params: { course_resource: valid_params }
        expect_create_success_with_model('course_resource', admin_course_resources_url(course_1.id))
      end

      it 'should report error for invalid params' do
        post :create, params: { course_resource: {valid_params.keys.first => ''} }
        expect_create_error_with_model('course_resource')
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params for course_resource_1' do
        put :update, params: { id: course_resource_1.id, course_resource: valid_params }
        expect_update_success_with_model('course_resource', admin_course_resources_url(course_1.id))
      end

      it 'should reject invalid params' do
        put :update, params: { id: course_resource_1.id, course_resource: {valid_params.keys.first => ''} }
        expect_update_error_with_model('course_resource')
        expect(assigns(:course_resource).id).to eq(course_resource_1.id)
      end
    end


    describe "DELETE 'destroy'" do
      it 'should be ERROR as children exist' do
        delete :destroy, params: { id: course_resource_1.id }
        expect_delete_success_with_model('course_resource', admin_course_resources_url)
      end
    end

  end

end
