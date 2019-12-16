# == Schema Information
#
# Table name: subject_courses
#
#  id                                      :integer          not null, primary key
#  name                                    :string
#  name_url                                :string
#  sorting_order                           :integer
#  active                                  :boolean          default(FALSE), not null
#  cme_count                               :integer
#  video_count                             :integer
#  quiz_count                              :integer
#  question_count                          :integer
#  description                             :text
#  short_description                       :string
#  created_at                              :datetime         not null
#  updated_at                              :datetime         not null
#  best_possible_first_attempt_score       :float
#  default_number_of_possible_exam_answers :integer
#  total_video_duration                    :float            default(0.0)
#  destroyed_at                            :datetime
#  email_content                           :text
#  external_url_name                       :string
#  external_url                            :string
#  exam_body_id                            :integer
#  survey_url                              :string
#  group_id                                :integer
#  quiz_pass_rate                          :integer
#  total_estimated_time_in_seconds         :integer
#  background_image_file_name              :string
#  background_image_content_type           :string
#  background_image_file_size              :integer
#  background_image_updated_at             :datetime
#  preview                                 :boolean          default(FALSE)
#  computer_based                          :boolean          default(FALSE)
#  highlight_colour                        :string           default("#ef475d")
#  category_label                          :string
#  additional_text_label                   :string
#  constructed_response_count              :integer          default(0)
#

require 'rails_helper'

describe SubjectCoursesController, type: :controller do

  let(:content_management_user_group) { FactoryBot.create(:content_management_user_group) }
  let(:content_management_user) { FactoryBot.create(:content_management_user, user_group_id: content_management_user_group.id) }
  let!(:content_management_user_student_access) { FactoryBot.create(:complimentary_student_access, user_id: content_management_user.id) }
  let!(:group_1) { FactoryBot.create(:group) }
  let!(:subject_course_1)  { FactoryBot.create(:active_subject_course,
                                               group: group_1) }
  let!(:subject_course_2)  { FactoryBot.create(:active_subject_course,
                                               group: group_1,
                                               computer_based: true) }
  let(:exam_body) { create(:exam_body) }

  let!(:subject_course_5) { FactoryBot.create(:inactive_subject_course) }
  let!(:valid_params) { FactoryBot.attributes_for(:subject_course) }

  context 'Logged in as a content_management_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(content_management_user)
    end

    describe "GET 'index'" do
      it 'should respond OK' do
        get :index
        expect_index_success_with_model('subject_courses', 3)
      end
    end

    describe "GET 'show/1'" do
      it 'should see subject_course_1' do
        get :show, params: { id: subject_course_1.id }
        expect_show_success_with_model('subject_course', subject_course_1.id)
      end

      # optional - some other object
      it 'should see subject_course_2' do
        get :show, params: { id: subject_course_2.id }
        expect_show_success_with_model('subject_course', subject_course_2.id)
      end
    end

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new
        expect_new_success_with_model('subject_course')
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond OK with subject_course_1' do
        get :edit, params: { id: subject_course_1.id }
        expect_edit_success_with_model('subject_course', subject_course_1.id)
      end

      # optional
      it 'should respond OK with subject_course_2' do
        get :edit, params: { id: subject_course_2.id }
        expect_edit_success_with_model('subject_course', subject_course_2.id)
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, params: { subject_course: valid_params.merge(group_id: group_1.id, exam_body_id: exam_body.id) }
        expect_create_success_with_model('subject_course', subject_courses_url)
      end

      it 'should report error for invalid params' do
        post :create, params: { subject_course: {valid_params.keys.first => ''} }
        expect_create_error_with_model('subject_course')
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params for subject_course_1' do
        put :update, params: { id: subject_course_1.id, subject_course: valid_params }
        expect_update_success_with_model('subject_course', subject_courses_url)
      end

      # optional
      it 'should respond OK to valid params for subject_course_2' do
        put :update, params: { id: subject_course_2.id, subject_course: valid_params }
        expect_update_success_with_model('subject_course', subject_courses_url)
        expect(assigns(:subject_course).id).to eq(subject_course_2.id)
      end

      it 'should reject invalid params' do
        put :update, params: { id: subject_course_1.id, subject_course: {valid_params.keys.first => ''} }
        expect_update_error_with_model('subject_course')
        expect(assigns(:subject_course).id).to eq(subject_course_1.id)
      end
    end

    describe "POST 'reorder'" do
      it 'should be OK with valid_array' do
        post :reorder, params: { array_of_ids: [subject_course_2.id, subject_course_1.id] }
        expect_reorder_success
      end
    end

    describe "DELETE 'destroy'" do
      it 'should be OK even though dependencies exist' do
        delete :destroy, params: { id: subject_course_1.id }
        expect_archive_success_with_model('subject_course', subject_course_1.id, subject_courses_url)
      end

      it 'should be OK as no dependencies exist' do
        delete :destroy, params: { id: subject_course_5.id }
        expect_delete_success_with_model('subject_course', subject_courses_url)
      end
    end

    describe '#clone' do
      context 'clone subject course' do
        it 'should duplicate subject course' do
          post :clone, params: { id: subject_course_1.id }

          expect(response.status).to eq(302)
          expect(response).to redirect_to(subject_courses_url)
          expect(flash[:success]).to be_present
          expect(flash[:success]).to eq('Course successfully duplicaded')
        end

        it 'should not duplicate subject course' do
          subject_course_dup = subject_course_1.dup
          subject_course_dup.update(name:  "#{subject_course_1.name} copy", name_url:  "#{subject_course_1.name}_copy")
          post :clone, params: { id: subject_course_1.id }

          expect(response.status).to eq(302)
          expect(response).to redirect_to(subject_courses_url)
          expect(flash[:error]).to be_present
          expect(flash[:error]).to eq('Course not successfully duplicaded')
        end
      end
    end
  end
end
