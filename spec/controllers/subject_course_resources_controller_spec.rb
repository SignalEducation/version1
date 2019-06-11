# == Schema Information
#
# Table name: subject_course_resources
#
#  id                       :integer          not null, primary key
#  name                     :string
#  subject_course_id        :integer
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

describe SubjectCourseResourcesController, type: :controller do

  let(:content_management_user_group) { FactoryBot.create(:content_management_user_group) }
  let(:content_management_user) { FactoryBot.create(:content_management_user, user_group_id: content_management_user_group.id) }
  let!(:content_management_user_student_access) { FactoryBot.create(:complimentary_student_access, user_id: content_management_user.id) }
  let!(:group_1) { FactoryBot.create(:group) }
  let!(:subject_course_1)  { FactoryBot.create(:active_subject_course,
                                               group_id: group_1.id,
                                               exam_body_id: 1) }

  let!(:subject_course_resource_1) { FactoryBot.create(:subject_course_resource, subject_course_id: subject_course_1.id) }
  let!(:subject_course_resource_2) { FactoryBot.create(:subject_course_resource) }
  let!(:valid_params) { FactoryBot.attributes_for(:subject_course_resource) }

  #TODO - review this controller with SubjectCourses controller. Is this needed?
  #TODO - the new, create and index are not used - versions in subject_courses controller
  context 'Logged in as a content_management_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(content_management_user)
    end

    describe "GET 'index'" do
      it 'should respond OK' do
        get :index
        expect_index_success_with_model('subject_course_resources', 2)
      end
    end

    describe "GET 'show/1'" do
      it 'should see subject_course_resource_1' do
        get :show, id: subject_course_resource_1.id
        expect_show_success_with_model('subject_course_resource', subject_course_resource_1.id)
      end

      # optional - some other object
      it 'should see subject_course_resource_2' do
        get :show, id: subject_course_resource_2.id
        expect_show_success_with_model('subject_course_resource', subject_course_resource_2.id)
      end
    end

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new
        expect_new_success_with_model('subject_course_resource')
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond OK with subject_course_resource_1' do
        get :edit, id: subject_course_resource_1.id
        expect_edit_success_with_model('subject_course_resource', subject_course_resource_1.id)
      end

      # optional
      it 'should respond OK with subject_course_resource_2' do
        get :edit, id: subject_course_resource_2.id
        expect_edit_success_with_model('subject_course_resource', subject_course_resource_2.id)
      end
    end

    describe "POST 'create'" do
      xit 'should report OK for valid params' do
        post :create, subject_course_resource: valid_params
        expect_create_success_with_model('subject_course_resource', course_resources_url(subject_course_1.id))
      end

      it 'should report error for invalid params' do
        post :create, subject_course_resource: {valid_params.keys.first => ''}
        expect_create_error_with_model('subject_course_resource')
      end
    end

    describe "PUT 'update/1'" do
      xit 'should respond OK to valid params for subject_course_resource_1' do
        put :update, id: subject_course_resource_1.id, subject_course_resource: valid_params
        expect_update_success_with_model('subject_course_resource', course_resources_url(subject_course_1.id))
      end

      it 'should reject invalid params' do
        put :update, id: subject_course_resource_1.id, subject_course_resource: {valid_params.keys.first => ''}
        expect_update_error_with_model('subject_course_resource')
        expect(assigns(:subject_course_resource).id).to eq(subject_course_resource_1.id)
      end
    end


    describe "DELETE 'destroy'" do
      it 'should be ERROR as children exist' do
        delete :destroy, id: subject_course_resource_1.id
        expect_delete_success_with_model('subject_course_resource', subject_course_resources_url)
      end
    end

  end

end
