# == Schema Information
#
# Table name: course_module_elements
#
#  id                               :integer          not null, primary key
#  name                             :string
#  name_url                         :string
#  description                      :text
#  estimated_time_in_seconds        :integer
#  course_module_id                 :integer
#  sorting_order                    :integer
#  created_at                       :datetime
#  updated_at                       :datetime
#  is_video                         :boolean          default(FALSE), not null
#  is_quiz                          :boolean          default(FALSE), not null
#  active                           :boolean          default(TRUE), not null
#  seo_description                  :string
#  seo_no_index                     :boolean          default(FALSE)
#  destroyed_at                     :datetime
#  number_of_questions              :integer          default(0)
#  duration                         :float            default(0.0)
#  temporary_label                  :string
#  is_constructed_response          :boolean          default(FALSE), not null
#  available_on_trial               :boolean          default(FALSE)
#  related_course_module_element_id :integer
#

require 'rails_helper'
require 'support/course_content'
require 'support/vimeo_web_mock_helpers'

describe CourseModuleElementsController, type: :controller do

  let(:content_management_user_group) { FactoryBot.create(:content_management_user_group) }
  let(:content_management_user) { FactoryBot.create(:content_management_user,
                                                    user_group: content_management_user_group) }
  let!(:group) { FactoryBot.create(:group) }
  let!(:exam_body) { FactoryBot.create(:exam_body) }
  let!(:subject_course)  { FactoryBot.create(:active_subject_course, group_id: group.id, exam_body_id: exam_body.id) }
  let!(:course_section) { FactoryBot.create(:course_section,
                                            subject_course: subject_course) }
  let!(:course_module) { FactoryBot.create(:active_course_module,
                                           course_section: course_section,
                                           subject_course: subject_course) }
  let!(:course_module_element_1_1) { FactoryBot.create(:cme_quiz,
                                                       course_module: course_module) }
  let!(:course_module_element_1_2) { FactoryBot.create(:cme_video,
                                                       course_module: course_module) }
  let!(:course_module_element_1_3) { FactoryBot.create(:cme_video,
                                                       course_module: course_module) }
  let!(:course_module_element_1_4) { FactoryBot.create(:cme_constructed_response,
                                                       course_module: course_module) }

  let!(:course_module_element_quiz_1_1) { FactoryBot.create(:course_module_element_quiz,
                                                            course_module_element: course_module_element_1_1) }
  let!(:course_module_element_video_1_1_1) { FactoryBot.create(:course_module_element_video,
                                                               course_module_element: course_module_element_1_2,
                                                               vimeo_guid: 'abc123') }
  let!(:course_module_element_video_1_1_2) { FactoryBot.create(:course_module_element_video,
                                                               course_module_element: course_module_element_1_3,
                                                               vimeo_guid: '123abc') }
  let!(:constructed_response_1) { FactoryBot.create(:constructed_response,
                                                    course_module_element: course_module_element_1_4) }


  let!(:valid_params) { course_module_element_1_1.attributes.merge({name: 'ABCDE', name_url: 'adcbw', vimeo_guid: '123abc123'}) }

  let!(:cme_video_params) { FactoryBot.attributes_for(:course_module_element_video) }
  let!(:valid_video_params) { course_module_element_1_3.attributes.merge({name: 'Video 01', name_url: 'video_01', course_module_element_video_attributes: cme_video_params}) }
  let!(:constructed_response_params) { course_module_element_1_4.attributes.merge({name: 'CR 01', name_url: 'cr_01'}) }
  let!(:update_constructed_response_params) { course_module_element_1_4.attributes.merge({name: 'CR 01 - Edited', name_url: 'cr_01'}) }


  context 'Logged in as a content_management_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(content_management_user)
    end

    describe "GET 'show/1'" do
      it 'should respond OK' do
        get :show, params: { id: course_module_element_1_1.id }
        expect_show_success_with_model('course_module_element', course_module_element_1_1.id)
      end
    end

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new, params: { cm_id: course_module.id }
        expect_new_success_with_model('course_module_element')
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond OK with course_module_element_1_1 - quiz' do
        get :edit, params: { id: course_module_element_1_1.id }
        expect_edit_success_with_model('course_module_element', course_module_element_1_1.id)
      end

      # Vimeo Upload Ticket Build Stubbed
      it 'should respond OK with course_module_element_1_2 - video' do

        get :edit, params: { id: course_module_element_1_2.id }
        expect_edit_success_with_model('course_module_element', course_module_element_1_2.id)
      end

      it 'should respond OK with course_module_element_1_3 - constructed_response' do
        get :edit, params: { id: course_module_element_1_4.id }
        expect_edit_success_with_model('course_module_element', course_module_element_1_4.id)
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, params: { course_module_element: valid_params }
        expect_create_success_with_model('course_module_element', subject.course_module_special_link(course_module))
      end

      it 'should report OK for valid_video_params' do
        post :create, params: { course_module_element: valid_video_params }
        expect_create_success_with_model('course_module_element', subject.course_module_special_link(course_module))

      end

      it 'should report OK for constructed_response_params' do
        post :create, params: { course_module_element: constructed_response_params }
        expect_create_success_with_model('course_module_element', subject.course_module_special_link(course_module))
      end

      it 'should report error for invalid params' do
        post :create, params: { course_module_element: { valid_params.keys.first => '' } }
        expect_create_error_with_model('course_module_element')
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params for course_module_element_1_1' do
        put :update, params: { id: course_module_element_1_1.id, course_module_element: valid_params }
        expect_update_success_with_model('course_module_element', subject.course_module_special_link(course_module))
      end

      # optional
      it 'should respond OK to valid params for course_module_element_1_2' do
        put :update, params: { id: course_module_element_1_2.id, course_module_element: valid_params }
        expect_update_success_with_model('course_module_element', subject.course_module_special_link(course_module))
        expect(assigns(:course_module_element).id).to eq(course_module_element_1_2.id)
      end

      it 'should report OK for constructed_response_params' do
        post :update, params: { id: course_module_element_1_4.id, course_module_element: update_constructed_response_params }
        expect_update_success_with_model('course_module_element', subject.course_module_special_link(course_module))
        expect(assigns(:course_module_element).id).to eq(course_module_element_1_4.id)
      end

      it 'should reject invalid params' do
        put :update, params: { id: course_module_element_1_1.id, course_module_element: {name_url: ''} }
        expect_update_error_with_model('course_module_element')
        expect(assigns(:course_module_element).id).to eq(course_module_element_1_1.id)
      end
    end

    describe "POST 'reorder'" do
      it 'should be OK with valid_array' do
        post :reorder, params: { array_of_ids: [course_module_element_1_1.id, course_module_element_1_2.id] }
        expect_reorder_success
      end
    end

    describe "DELETE 'destroy'" do
      it 'should be OK as no dependencies exist' do
        delete :destroy, params: { id: course_module_element_1_3.id }
        expect_delete_success_with_model('course_module_element', subject.course_module_special_link(course_module_element_1_3.course_module))
      end
    end

    describe "GET 'quiz_questions_order'" do
      it 'should respond ERROR not permitted' do
        get :quiz_questions_order, params: { id: course_module_element_1_1.id }
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:quiz_questions_order)
      end
    end
  end
end
