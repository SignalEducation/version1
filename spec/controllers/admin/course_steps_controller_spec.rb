# == Schema Information
#
# Table name: course_steps
#
#  id                               :integer          not null, primary key
#  name                             :string
#  name_url                         :string
#  description                      :text
#  estimated_time_in_seconds        :integer
#  course_lesson_id                 :integer
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
#  related_course_step_id :integer
#  vid_end_seconds                  :integer

require 'rails_helper'
require 'support/course_content'
require 'support/vimeo_web_mock_helpers'

describe Admin::CourseStepsController, type: :controller do

  let(:content_management_user_group) { create(:content_management_user_group) }
  let(:content_management_user)       { create(:content_management_user, user_group: content_management_user_group) }
  let!(:exam_body_1)                  { create(:exam_body) }
  let!(:group_1)                      { create(:group, exam_body_id: exam_body_1.id) }
  let!(:course_1)             { create(:active_course, group_id: group_1.id, exam_body_id: exam_body_1.id) }
  let!(:course_2)             { create(:active_course, group_id: group_1.id, computer_based: true, exam_body_id: exam_body_1.id) }

  include_context 'course_content'

  let!(:valid_params)                       { attributes_for(:course_video, name: 'ABCDE', name_url: 'adcbw', vimeo_guid: '123abc123') }

  let!(:video_step_params)                   { attributes_for(:course_video, :vimeo, dacast_id: 1234) }
  let!(:quiz_step_params)                    { course_step_1.attributes.merge({name: 'Quiz 01', name_url: 'qz_01'}) }
  let!(:valid_video_params)                 { course_step_3.attributes.merge({name: 'Video 01', name_url: 'video_01', course_video_attributes: video_step_params}) }
  let!(:constructed_response_params)        { course_step_4.attributes.merge({name: 'CR 01', name_url: 'cr_01'}) }
  let!(:update_constructed_response_params) { course_step_4.attributes.merge({name: 'CR 01 - Edited', name_url: 'cr_01'}) }


  context 'Logged in as a content_management_user: ' do
    before(:each) do
      activate_authlogic
      UserSession.create!(content_management_user)
    end

    describe "GET 'show/1'" do
      it 'should respond OK' do
        get :show, params: { id: course_step_1.id }
        expect_show_success_with_model('course_step', course_step_1.id)
      end
    end

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new, params: { cm_id: course_lesson_1.id }
        expect_new_success_with_model('course_step')
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond OK with course_step_1 - quiz' do
        get :edit, params: { id: course_step_1.id }
        expect_edit_success_with_model('course_step', course_step_1.id)
      end

      # Vimeo Upload Ticket Build Stubbed
      it 'should respond OK with course_step_2 - video' do

        get :edit, params: { id: course_step_2.id }
        expect_edit_success_with_model('course_step', course_step_2.id)
      end

      it 'should respond OK with course_step_4 - constructed_response' do
        get :edit, params: { id: course_step_4.id }
        expect_edit_success_with_model('course_step', course_step_4.id)
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, params: { course_step: quiz_step_params }
        expect_create_success_with_model('course_step', admin_show_course_lesson_url(course_lesson_1.course_id, course_lesson_1.course_section.id, course_lesson_1.id))
      end

      it 'should report OK for valid_video_params' do
        post :create, params: { course_step: valid_video_params }
        expect_create_success_with_model('course_step', admin_show_course_lesson_url(course_lesson_1.course_id, course_lesson_1.course_section.id, course_lesson_1.id))

      end

      it 'should report OK for constructed_response_params' do
        post :create, params: { course_step: constructed_response_params }
        expect_create_success_with_model('course_step', admin_show_course_lesson_url(course_lesson_1.course_id, course_lesson_1.course_section.id, course_lesson_1.id))
      end

      it 'should report error for invalid params' do
        post :create, params: { course_step: { valid_params.keys.first => '' } }
        expect_create_error_with_model('course_step')
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params for course_step_1_1' do
        put :update, params: { id: course_step_1.id, course_step: valid_params }
        expect_update_success_with_model('course_step', admin_show_course_lesson_url(course_lesson_1.course_id, course_lesson_1.course_section_id, course_lesson_1))
      end

      # optional
      it 'should respond OK to valid params for course_step_1_2' do
        put :update, params: { id: course_step_2.id, course_step: valid_params }
        expect_update_success_with_model('course_step', admin_show_course_lesson_url(course_lesson_1.course_id, course_lesson_1.course_section_id, course_lesson_1))
        expect(assigns(:course_step).id).to eq(course_step_2.id)
      end

      it 'should report OK for constructed_response_params' do
        post :update, params: { id: course_step_4.id, course_step: update_constructed_response_params }
        expect_update_success_with_model('course_step', admin_show_course_lesson_url(course_lesson_1.course_id, course_lesson_1.course_section_id, course_lesson_1))
        expect(assigns(:course_step).id).to eq(course_step_4.id)
      end

      it 'should reject invalid params' do
        put :update, params: { id: course_step_1.id, course_step: {name_url: ''} }
        expect_update_error_with_model('course_step')
        expect(assigns(:course_step).id).to eq(course_step_1.id)
      end
    end

    describe "POST 'reorder'" do
      it 'should be OK with valid_array' do
        post :reorder, params: { array_of_ids: [course_step_1.id, course_step_2.id] }
        expect_reorder_success
      end
    end

    describe "DELETE 'destroy'" do
      it 'should be OK as no dependencies exist' do
        delete :destroy, params: { id: course_step_3.id }

        expect_delete_success_with_model('course_step',
                                         admin_show_course_lesson_url(course_step_3.course_lesson.course_id, course_step_3.course_lesson.course_section.id, course_step_3.course_lesson.id))
      end
    end

    describe "GET 'quiz_questions_order'" do
      it 'should respond ERROR not permitted' do
        get :quiz_questions_order, params: { id: course_step_1.id }
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:quiz_questions_order)
      end
    end

    describe '#clone' do
      context 'ContructResponse' do
        it 'should duplicate constructed response' do
          post :clone, params: { course_step_id: course_step_4.id }

          expect(response.status).to eq(302)
          expect(flash[:success]).to be_present
          expect(flash[:success]).to eq('Constructed Response successfully duplicated')
          expect(response).to redirect_to(admin_show_course_lesson_path(course_step_4.course_lesson.course_id,
                                                                        course_step_4.course_lesson.course_section.id,
                                                                        course_step_4.course_lesson.id))
        end

        it 'should not duplicate constructed response' do
          expect_any_instance_of(CourseStep).to receive(:type_name).and_return('')
          post :clone, params: { course_step_id: course_step_4.id }

          expect(response.status).to eq(302)
          expect(flash[:error]).to be_present
          expect(flash[:error]).to eq('Course Element was not successfully duplicated')
          expect(response).to redirect_to(admin_show_course_lesson_path(course_step_4.course_lesson.course_id,
                                                                        course_step_4.course_lesson.course_section.id,
                                                                        course_step_4.course_lesson.id))
        end
      end

      context 'Quiz' do
        it 'should duplicate quiz' do
          post :clone, params: { course_step_id: course_step_1.id }

          expect(response.status).to eq(302)
          expect(flash[:success]).to be_present
          expect(flash[:success]).to eq('Quiz successfully duplicated')
          expect(response).to redirect_to(admin_show_course_lesson_path(course_step_1.course_lesson.course_id,
                                                                        course_step_1.course_lesson.course_section.id,
                                                                        course_step_1.course_lesson.id))
        end

        it 'should not duplicate quiz' do
          expect_any_instance_of(CourseStep).to receive(:type_name).and_return('')
          post :clone, params: { course_step_id: course_step_1.id }

          expect(response.status).to eq(302)
          expect(flash[:error]).to be_present
          expect(flash[:error]).to eq('Course Element was not successfully duplicated')
          expect(response).to redirect_to(admin_show_course_lesson_path(course_step_1.course_lesson.course_id,
                                                                        course_step_1.course_lesson.course_section.id,
                                                                        course_step_1.course_lesson.id))
        end
      end

      context 'Video' do
        it 'should duplicate video' do
          post :clone, params: { course_step_id: course_step_3.id }

          expect(response.status).to eq(302)
          expect(flash[:success]).to be_present
          expect(flash[:success]).to eq('Video successfully duplicated')
          expect(response).to redirect_to(admin_show_course_lesson_path(course_step_3.course_lesson.course_id,
                                                                        course_step_3.course_lesson.course_section.id,
                                                                        course_step_3.course_lesson.id))
        end

        it 'should not duplicate video' do
          expect_any_instance_of(CourseStep).to receive(:type_name).and_return('')
          post :clone, params: { course_step_id: course_step_3.id }

          expect(response.status).to eq(302)
          expect(flash[:error]).to be_present
          expect(flash[:error]).to eq('Course Element was not successfully duplicated')
          expect(response).to redirect_to(admin_show_course_lesson_path(course_step_3.course_lesson.course_id,
                                                                        course_step_3.course_lesson.course_section.id,
                                                                        course_step_3.course_lesson.id))
        end
      end
    end
  end
end
