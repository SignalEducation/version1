require 'rails_helper'
require 'support/course_content'

RSpec.describe CoursesController, type: :controller do
  let!(:exam_body_1)                  { create(:exam_body) }
  let!(:group_1)                      { create(:group, exam_body_id: exam_body_1.id) }
  let!(:course_1)                     { create(:active_course,
                                               group_id: group_1.id,
                                               exam_body_id: exam_body_1.id) }
  let!(:course_2)                     { create(:active_course,
                                               group_id: group_1.id,
                                               computer_based: true,
                                               exam_body_id: exam_body_1.id) }
  let!(:standard_exam_sitting)        { create(:standard_exam_sitting,
                                               course_id: course_1.id,
                                               exam_body_id: exam_body_1.id) }
  let!(:computer_based_exam_sitting)  { create(:computer_based_exam_sitting,
                                               course_id: course_2.id,
                                               exam_body_id: exam_body_1.id) }
  include_context 'course_content' # support/course_content.rb
  let!(:student_user_group )          { create(:student_user_group ) }
  let!(:basic_student)                { create(:basic_student, user_group_id: student_user_group.id) }
  let!(:scul)                         { create(:course_log, user_id: basic_student.id,
                                               course_id: course_1.id) }
  let!(:enrollment)                   { create(:enrollment, user_id: basic_student.id, active: true,
                                               course_log_id: scul.id,
                                               exam_sitting_id: standard_exam_sitting.id,
                                               course_id: course_1.id) }

  let!(:csul) { create(:course_section_log, user_id: basic_student.id,
                       course_section_id: course_section_1.id, course_id: course_1.id,
                       course_log_id: scul.id) }

  let!(:course_lesson_log) { create(:course_lesson_log, user_id: basic_student.id,
                                    course_lesson_id: course_lesson_1.id, course_id: course_1.id,
                                    course_section_log_id: csul.id, course_log_id: scul.id,
                                    course_section_id: course_section_1.id,
                                    latest_course_step_id: course_step_2.id) }
  let!(:video_log) { create(:video_cmeul, user_id: basic_student.id,
                            course_lesson_log_id: course_lesson_log.id,
                            course_lesson_id: course_lesson_1.id,
                            course_id: course_1.id,
                            course_section_id: course_section_1.id,
                            course_step_id: course_step_2.id) }

  let!(:cr_cmeul) { create(:cr_cmeul, course_step_id: course_step_4.id,
                           course_id: course_1.id,
                           course_section_id: course_section_1.id,
                           course_lesson_id: course_lesson_1.id,
                           course_log_id: scul.id,
                           course_section_log_id: csul.id,
                           course_lesson_log_id: course_lesson_log.id,
                           user_id: basic_student.id, element_completed: false,
                           quiz_attempts_attributes:
                             {"0"=>{"user_id"=>basic_student.id, "quiz_question_id"=>quiz_question_1.id,
                                   "quiz_answer_id"=>quiz_answer_1.id, "answer_array"=>"282,283,281,284"},
                             "1"=>{"user_id"=>basic_student.id, "quiz_question_id"=>quiz_question_2.id,
                                   "quiz_answer_id"=>quiz_answer_2.id, "answer_array"=>"288,287,285,286"}}) }

  let!(:constructed_response_attempt_1) { create(:constructed_response_attempt,
                                                 constructed_response_id: constructed_response_1.id,
                                                 scenario_id: scenario_1.id,
                                                 course_step_id: course_step_4.id,
                                                 course_step_log_id: cr_cmeul.id,
                                                 user_id: basic_student.id) }
  let!(:constructed_response_attempt_2) { create(:constructed_response_attempt,
                                                 constructed_response_id: constructed_response_1.id,
                                                 scenario_id: scenario_1.id,
                                                 course_step_id: course_step_4.id,
                                                 course_step_log_id: cr_cmeul.id,
                                                 user_id: basic_student.id) }
  let!(:scenario_question_attempt_1) { create(:scenario_question_attempt,
                                              scenario_question_id: scenario_question_1.id,
                                              constructed_response_attempt_id: constructed_response_attempt_1.id,
                                              user_id: basic_student.id) }
  let!(:scenario_answer_attempt_1) { create(:scenario_answer_attempt,
                                            scenario_question_attempt_id: scenario_question_attempt_1.id,
                                            scenario_answer_template_id: scenario_answer_template_1.id,
                                            user_id: basic_student.id, editor_type: 'text_editor') }

  describe 'Logged in as Basic Student User' do
    let!(:_system) { create(:system_setting) }

    before(:each) do
      activate_authlogic
      UserSession.create!(basic_student)
    end

    describe 'Get show returns http success ' do
      it 'for Course Video' do
        get :show, params: { course_name_url: course_1.name_url, course_section_name_url: course_section_1.name_url, course_lesson_name_url: course_lesson_1.name_url, course_step_name_url: course_step_2.name_url }

        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:show)
      end

      it 'for Course Quiz' do
        get :show, params: { course_name_url: course_1.name_url, course_section_name_url: course_section_1.name_url, course_lesson_name_url: course_lesson_1.name_url, course_step_name_url: course_step_1.name_url }

        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:show)
      end

      it 'for Course Notes' do
        get :show, params: { course_name_url: course_1.name_url, course_section_name_url: course_section_1.name_url, course_lesson_name_url: course_lesson_1.name_url, course_step_name_url: course_step_5.name_url }

        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:show)
      end

      it 'for Course Contructive Response' do
        get :show, params: { course_name_url: course_1.name_url, course_section_name_url: course_section_1.name_url, course_lesson_name_url: course_lesson_1.name_url, course_step_name_url: course_step_4.name_url }

        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:show)
      end
    end

    describe 'Post to create with CMEUL data for CMEQ' do
      it 'should report OK for valid params' do
        patch :update, params: { id: cr_cmeul.id, course_step_log: cr_cmeul.attributes }

        expect(response.status).to eq(200)
        expect(response).to render_template(:show)
      end

      it 'should respond to JSON with status 201' do
        params = { params: { "course_step_log"=> { "id"=>cr_cmeul.id, user_id: nil },"id"=>constructed_response_attempt_1.id }, format: :json }

        patch :update, params

        expect(response.status).to eq(302)
      end
    end

    describe 'Post to video_watched_data with CMEUL data for CMEQ' do
      it 'should respond to JSON with status 200' do
        post :video_watched_data, params: { video_log_id: video_log.id, cme_id: course_step_2.id }, format: :json
        expect(response.status).to eq(200)
      end
    end

    describe 'Post to video_watched_data with CMEUL data for CMEQ' do
      it 'should respond to JSON with status 200' do
        post :create_video_user_log, params: { cmeId: course_step_2.id, scul_id: scul.id }, format: :json
        expect(response.status).to eq(200)
      end
    end

    describe 'Get to show_constructed_response with CMEUL data for CR' do
      it 'should respond to JSON with status 200' do
        get :show_constructed_response, params: { course_name_url: course_1.name_url, course_section_name_url: course_section_1.name_url, course_lesson_name_url: course_lesson_1.name_url, course_step_name_url: course_step_4.name_url }
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:show_constructed_response)
      end
    end

    describe 'Post to update_constructed_response_user_log with CMEUL data for CR' do
      xit 'should respond to JSON with status 201' do
        cr_params = {params: {"course_step_log"=> {"id"=>cr_cmeul.id, "constructed_response_attempt_attributes"=>
            {"user_id"=>basic_student.id, "constructed_response_id"=>constructed_response_1.id, "scenario_id"=>scenario_1.id,
             "course_step_id"=>course_step_4.id, "original_scenario_text_content"=> "original scenario text",
             "user_edited_scenario_text_content"=> "user edited scenario text", "scratch_pad_text"=>"You can write notes here...",
             "scenario_question_attempts_attributes"=>
                 {"0"=> {"constructed_response_attempt_id"=>constructed_response_attempt_1.id, "user_id"=>basic_student.id,
                         "scenario_question_id"=>scenario_question_1.id, "status"=>"Seen", "flagged_for_review"=>"false",
                         "original_scenario_question_text"=> "original scenario question text",
                         "user_edited_scenario_question_text"=> "user edited scenario question text",

                         "scenario_answer_attempts_attributes"=>
                             {"0"=> {"scenario_question_attempt_id"=>scenario_question_attempt_1.id,
                                     "user_id"=>basic_student.id,
                                     "editor_type"=>scenario_answer_template_1.editor_type,
                                     "scenario_answer_template_id"=>scenario_answer_template_1.id,
                                     "original_answer_template_text"=>"", "user_edited_answer_template_text"=>"",
                                     "id"=>scenario_answer_attempt_1.id}},
                         "id"=>scenario_question_attempt_1.id}
                 },
             "id"=>constructed_response_attempt_1.id}
        }}, format: :json }

        patch :update_constructed_response_user_log, cr_params
        expect(response.status).to eq(201)
        expect(JSON.parse(response.body).first[1]).to eq(cr_cmeul.id)
      end
    end

    describe 'Get submit_constructed_response_user_log with CMEUL data for CR for final submit' do
      it 'should respond ok and redirect to ' do
        get :submit_constructed_response_user_log, params: { cmeul_id: cr_cmeul.id, user_id: nil }
        course_url = show_course_url(cr_cmeul.course_step.course_lesson.course_section.course.name_url,
                                cr_cmeul.course_step.course_lesson.course_section.name_url,
                                cr_cmeul.course_step.course_lesson.name_url,
                                cr_cmeul.course_step.name_url)

        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(302)
        expect(response).to redirect_to(course_url)
      end
    end
  end
end
