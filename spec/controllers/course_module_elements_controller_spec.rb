# == Schema Information
#
# Table name: course_module_elements
#
#  id                        :integer          not null, primary key
#  name                      :string
#  name_url                  :string
#  description               :text
#  estimated_time_in_seconds :integer
#  course_module_id          :integer
#  sorting_order             :integer
#  created_at                :datetime
#  updated_at                :datetime
#  is_video                  :boolean          default(FALSE), not null
#  is_quiz                   :boolean          default(FALSE), not null
#  active                    :boolean          default(TRUE), not null
#  seo_description           :string
#  seo_no_index              :boolean          default(FALSE)
#  destroyed_at              :datetime
#  number_of_questions       :integer          default(0)
#  duration                  :float            default(0.0)
#  temporary_label           :string
#  is_constructed_response   :boolean          default(FALSE), not null
#

require 'rails_helper'
require 'support/course_content'
require 'support/vimeo_web_mock_helpers'

describe CourseModuleElementsController, type: :controller do

  let!(:group_1) { FactoryBot.create(:group) }
  let!(:subject_course_1)  { FactoryBot.create(:active_subject_course, group_id: 1, exam_body_id: 1) }
  let!(:subject_course_2)  { FactoryBot.create(:active_subject_course, group_id: 1, computer_based: true, exam_body_id: 1) }
  include_context 'course_content'
  let(:content_management_user_group) { FactoryBot.create(:content_management_user_group) }
  let(:content_management_user) { FactoryBot.create(:content_management_user,
                                                    user_group_id: content_management_user_group.id) }

  let!(:valid_params) { course_module_element_1_1.attributes.merge({name: 'ABCDE', name_url: 'adcbw'}) }

  let!(:cme_video_params) { FactoryBot.attributes_for(:course_module_element_video) }
  let!(:valid_video_params) { course_module_element_1_3.attributes.merge({name: 'Video 01', name_url: 'video_01', course_module_element_video_attributes: cme_video_params}) }

  #TODO - add tests for Constructed Response CMEs

  context 'Logged in as a content_management_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(content_management_user)
    end

    describe "GET 'show/1'" do
      it 'should respond OK' do
        get :show, id: course_module_element_1_1.id
        expect_show_success_with_model('course_module_element', course_module_element_1_1.id)
      end
    end

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new, cm_id: course_module_1.id
        expect_new_success_with_model('course_module_element')
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond OK with course_module_element_1_1 - quiz' do
        get :edit, id: course_module_element_1_1.id
        expect_edit_success_with_model('course_module_element', course_module_element_1_1.id)
      end

      # Vimeo Upload Ticket Build Stubbed
      it 'should respond OK with course_module_element_1_2 - video' do
        url = 'https://api.vimeo.com/me/videos'
        redirect_url = "http://test.host/en/course_module_elements/#{course_module_element_1_2.id}/edit?cm_id=#{course_module_element_1_2.course_module.id}&course_module_element_id=#{course_module_element_1_2.id}&type=video"
        vimeo_request_body = {"redirect_url"=>redirect_url}
        stub_vimeo_post_request(url, redirect_url, vimeo_request_body)

        get :edit, id: course_module_element_1_2.id
        expect_edit_success_with_model('course_module_element', course_module_element_1_2.id)
        expect(a_request(:post, url).with(body: vimeo_request_body)).to have_been_made.once
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, course_module_element: valid_params
        expect_create_success_with_model('course_module_element', subject.course_module_special_link(course_module_1))
      end

      it 'should report OK for valid_video_params' do
        url = "https://api.vimeo.com/videos/#{cme_video_params[:vimeo_guid]}"
        vimeo_request_body = {"name"=>"Video 01"}
        stub_vimeo_patch_request(url, vimeo_request_body)

        post :create, course_module_element: valid_video_params
        expect_create_success_with_model('course_module_element', subject.course_module_special_link(course_module_1))

        expect(a_request(:patch, url).with(body: vimeo_request_body)).to have_been_made.once
      end

      it 'should report error for invalid params' do
        post :create, course_module_element: {valid_params.keys.first => ''}
        expect_create_error_with_model('course_module_element')
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params for course_module_element_1_1' do
        put :update, id: course_module_element_1_1.id, course_module_element: valid_params
        expect_update_success_with_model('course_module_element', subject.course_module_special_link(course_module_1))
      end

      # optional
      it 'should respond OK to valid params for course_module_element_1_2' do
        put :update, id: course_module_element_1_2.id, course_module_element: valid_params
        expect_update_success_with_model('course_module_element', subject.course_module_special_link(course_module_1))
        expect(assigns(:course_module_element).id).to eq(course_module_element_1_2.id)
      end

      it 'should reject invalid params' do
        put :update, id: course_module_element_1_1.id, course_module_element: {name_url: ''}
        expect_update_error_with_model('course_module_element')
        expect(assigns(:course_module_element).id).to eq(course_module_element_1_1.id)
      end
    end

    describe "POST 'reorder'" do
      it 'should be OK with valid_array' do
        post :reorder, array_of_ids: [course_module_element_2_1.id, course_module_element_2_2.id]
        expect_reorder_success
      end
    end

    describe "DELETE 'destroy'" do

      it 'should be OK as no dependencies exist' do
        url = "https://api.vimeo.com/videos/#{course_module_element_video_1_1_2.vimeo_guid}"
        stub_vimeo_delete_request(url)

        delete :destroy, id: course_module_element_1_3.id
        expect_delete_success_with_model('course_module_element', subject.course_module_special_link(course_module_element_1_3.course_module))

        expect(a_request(:delete, url).with(body: '')).to have_been_made.once

      end
    end

    describe "GET 'quiz_questions_order'" do
      it 'should respond ERROR not permitted' do
        get :quiz_questions_order, id: course_module_element_1_1.id
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:quiz_questions_order)
      end
    end

  end

end
