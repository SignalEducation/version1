require 'rails_helper'
require 'support/course_content'

RSpec.describe CoursesController, type: :controller do

  let!(:exam_body_1) { FactoryBot.create(:exam_body) }
  let!(:group_1) { FactoryBot.create(:group) }
  let!(:group_2) { FactoryBot.create(:group) }
  let!(:subject_course_1)  { FactoryBot.create(:active_subject_course,
                                               group_id: group_1.id,
                                               exam_body_id: exam_body_1.id) }
  let!(:subject_course_2)  { FactoryBot.create(:active_subject_course,
                                               group_id: group_1.id,
                                               computer_based: true,
                                               exam_body_id: exam_body_1.id) }
  let!(:standard_exam_sitting)  { FactoryBot.create(:standard_exam_sitting,
                                                    subject_course_id: subject_course_1.id) }
  let!(:computer_based_exam_sitting)  { FactoryBot.create(:computer_based_exam_sitting,
                                                          subject_course_id: subject_course_2.id) }
  include_context 'course_content'
  let!(:student_user_group ) { FactoryBot.create(:student_user_group ) }
  let!(:valid_trial_student) { FactoryBot.create(:valid_free_trial_student,
                                                 user_group_id: student_user_group.id) }
  let!(:valid_trial_student_access) { FactoryBot.create(:valid_free_trial_student_access,
                                                        user_id: valid_trial_student.id) }
  let!(:scul) { FactoryBot.create(:subject_course_user_log, user_id: valid_trial_student.id,
                                  subject_course_id: subject_course_1.id) }
  let!(:enrollment) { FactoryBot.create(:enrollment, user_id: valid_trial_student.id, active: true,
                                        subject_course_user_log_id: scul.id, exam_sitting_id: standard_exam_sitting.id,
                                        subject_course_id: subject_course_1.id) }

  let!(:student_exam_track) { FactoryBot.create(:student_exam_track, user_id: valid_trial_student.id,
                                       course_module_id: course_module_1.id, subject_course_id: subject_course_1.id,
                                       subject_course_user_log_id: scul.id,
                                       latest_course_module_element_id: course_module_element_1_3.id) }
  let!(:video_log) { FactoryBot.create(:video_cmeul, user_id: valid_trial_student.id,
                                       student_exam_track_id: student_exam_track.id,
                                       course_module_id: course_module_1.id,
                                       course_module_element_id: course_module_element_1_3.id) }

  let!(:cr_cmeul) { FactoryBot.create(:cr_cmeul, course_module_element_id: course_module_element_1_4.id,
                                      student_exam_track_id: student_exam_track.id,
                                      course_module_id: course_module_1.id,
                                        user_id: valid_trial_student.id, element_completed: false) }

  let!(:constructed_response_attempt_1) { FactoryBot.create(:constructed_response_attempt,
                                        constructed_response_id: constructed_response_1.id,
                                        course_module_element_id: course_module_element_1_4.id,
                                        course_module_element_user_log_id: cr_cmeul.id,
                                        user_id: valid_trial_student.id, scenario_id: scenario_1.id) }
  let!(:constructed_response_attempt_2) { FactoryBot.create(:constructed_response_attempt,
                                        constructed_response_id: constructed_response_1.id,
                                        course_module_element_id: course_module_element_1_4.id,
                                        course_module_element_user_log_id: cr_cmeul.id,
                                        user_id: valid_trial_student.id, scenario_id: scenario_1.id) }
  let!(:scenario_question_attempt_1) { FactoryBot.create(:scenario_question_attempt,
                                        constructed_response_attempt_id: constructed_response_attempt_1.id,
                                        scenario_question_id: scenario_question_1.id,
                                        user_id: valid_trial_student.id) }
  let!(:scenario_answer_attempt_1) { FactoryBot.create(:scenario_answer_attempt,
                                                       scenario_question_attempt_id: scenario_question_attempt_1.id,
                                                       scenario_answer_template_id: scenario_answer_template_1.id,
                                        user_id: valid_trial_student.id, editor_type: 'text_editor') }

  let!(:valid_cmeul_quiz_params) {
                                          {"subject_course_user_log_id"=> scul.id,
                                           "user_id"=>valid_trial_student.id,
                                           "course_module_id"=>course_module_1.id,
                                           "course_module_element_id"=>course_module_element_1_1.id,
                                           "time_taken_in_seconds"=>"211",
                                           "quiz_attempts_attributes"=>
                                               {"0"=>{"user_id"=>valid_trial_student.id, "quiz_question_id"=>quiz_question_1.id,
                                                      "quiz_answer_id"=>quiz_answer_1.id, "answer_array"=>"282,283,281,284"},
                                                "1"=>{"user_id"=>valid_trial_student.id, "quiz_question_id"=>quiz_question_2.id,
                                                      "quiz_answer_id"=>quiz_answer_2.id, "answer_array"=>"288,287,285,286"}} } }


  describe 'Logged in as Student User' do

    before(:each) do
      activate_authlogic
      UserSession.create!(valid_trial_student)
    end

    describe 'Get show returns http success ' do
      it 'for CMEV' do
        get :show, subject_course_name_url: subject_course_1.name_url, course_module_name_url: course_module_1.name_url, course_module_element_name_url: course_module_element_1_2.name_url
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:show)
      end

      it 'for CMEQ' do
        get :show, subject_course_name_url: subject_course_1.name_url, course_module_name_url: course_module_1.name_url, course_module_element_name_url: course_module_element_1_1.name_url
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:show)
      end

      it 'for CMECR' do
        get :show, subject_course_name_url: subject_course_1.name_url, course_module_name_url: course_module_1.name_url, course_module_element_name_url: course_module_element_1_4.name_url
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:show)
      end

    end


    describe 'Post to create with CMEUL data for CMEQ' do

      it 'should report OK for valid params' do
        post :create, course_module_element_user_log: valid_cmeul_quiz_params
        expect(response.status).to eq(200)
        expect(response).to render_template(:show)
      end

    end

    describe 'Post to video_watched_data with CMEUL data for CMEQ' do
      it 'should respond to JSON with status 200' do
        post :video_watched_data, {course: {videoLogId: video_log.id}, format: :json }
        expect(response.status).to eq(200)
      end

    end

    describe 'Post to video_watched_data with CMEUL data for CMEQ' do

      it 'should respond to JSON with status 200' do
        post :create_video_user_log, {course: {cmeId: course_module_element_1_3.id, scul_id: scul.id}, format: :json }
        expect(response.status).to eq(200)
        
      end

    end

    describe 'Get to show_constructed_response with CMEUL data for CR' do

      it 'should respond to JSON with status 200' do
        get :show_constructed_response, subject_course_name_url: subject_course_1.name_url, course_module_name_url: course_module_1.name_url, course_module_element_name_url: course_module_element_1_4.name_url
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:show_constructed_response)
      end

    end

    describe 'Post to update_constructed_response_user_log with CMEUL data for CR' do

      xit 'should respond to JSON with status 200' do
        cr_params = {"course_module_element_user_log"=> {"id"=>cr_cmeul.id, "constructed_response_attempt_attributes"=>
            {"user_id"=>valid_trial_student.id, "constructed_response_id"=>constructed_response_1.id, "scenario_id"=>scenario_1.id,
             "course_module_element_id"=>course_module_element_1_4.id, "original_scenario_text_content"=> "original scenario text",
             "user_edited_scenario_text_content"=> "user edited senario text", "scratch_pad_text"=>"You can write notes here...",
             "scenario_question_attempts_attributes"=>
                 {"0"=> {"constructed_response_attempt_id"=>constructed_response_attempt_1.id, "user_id"=>valid_trial_student.id,
                         "scenario_question_id"=>scenario_question_1.id, "status"=>"Seen", "flagged_for_review"=>"false",
                         "original_scenario_question_text"=> "original scenario question text",
                         "user_edited_scenario_question_text"=> "user edited scenario question text",
                         "scenario_answer_attempts_attributes"=>
                             {"0"=> {"scenario_question_attempt_id"=>scenario_question_attempt_1.id,
                                     "user_id"=>valid_trial_student.id,
                                     "scenario_answer_template_id"=>scenario_answer_template_1.id,
                                     "original_answer_template_text"=>"", "user_edited_answer_template_text"=>"",
                                     "id"=>scenario_question_attempt_1.id}}, "id"=>scenario_question_attempt_1.id}
                 },
             "id"=>constructed_response_attempt_1.id}
        }}

        patch :update_constructed_response_user_log, cr_params
        expect(response.status).to eq(200)
        expect(JSON.parse(response.body).first[1]).to eq(2)
      end

    end

    describe 'Get submit_constructed_response_user_log with CMEUL data for CR for final submit' do

      it 'should respond ok and redirect to ' do

        get :submit_constructed_response_user_log, cmeul_id: cr_cmeul.id
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(302)
        expect(response).to redirect_to(course_url(cr_cmeul.course_module_element.course_module.subject_course.name_url, cr_cmeul.course_module_element.course_module.name_url, cr_cmeul.course_module_element.name_url))
      end

    end

  end

end
