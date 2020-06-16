# == Schema Information
#
# Table name: courses
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

describe Admin::CoursesController, type: :controller do
  let(:content_management_user_group)           { create(:content_management_user_group) }
  let(:content_management_user)                 { create(:content_management_user, user_group_id: content_management_user_group.id) }
  let!(:group_1)                                { create(:group) }
  let!(:course_1)                               { create(:active_course, group: group_1) }
  let!(:course_2)                               { create(:active_course, group: group_1, computer_based: true) }
  let(:exam_body)                               { create(:exam_body) }
  let!(:course_5)                               { create(:inactive_course) }
  let!(:valid_params)                           { attributes_for(:course) }

  context 'Logged in as a content_management_user: ' do
    before(:each) do
      activate_authlogic
      UserSession.create!(content_management_user)
    end

    describe "GET 'index'" do
      it 'should respond OK' do
        get :index
        expect_index_success_with_model('courses', 3)
      end
    end

    describe "GET 'show/1'" do
      it 'should see course_1' do
        get :show, params: { id: course_1.id }
        expect_show_success_with_model('course', course_1.id)
      end

      # optional - some other object
      it 'should see course_2' do
        get :show, params: { id: course_2.id }
        expect_show_success_with_model('course', course_2.id)
      end
    end

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new
        expect_new_success_with_model('course')
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond OK with course_1' do
        get :edit, params: { id: course_1.id }
        expect_edit_success_with_model('course', course_1.id)
      end

      # optional
      it 'should respond OK with course_2' do
        get :edit, params: { id: course_2.id }
        expect_edit_success_with_model('course', course_2.id)
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, params: { course: valid_params.merge(group_id: group_1.id, exam_body_id: exam_body.id) }
        expect_create_success_with_model('course', admin_course_url(Course.last))
      end

      it 'should report error for invalid params' do
        post :create, params: { course: {valid_params.keys.first => ''} }
        expect_create_error_with_model('course')
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params for course_1' do
        put :update, params: { id: course_1.id, course: valid_params }
        expect_update_success_with_model('course', admin_course_url(course_1))
      end

      # optional
      it 'should respond OK to valid params for course_2' do
        put :update, params: { id: course_2.id, course: valid_params }
        expect_update_success_with_model('course', admin_course_url(course_2))
        expect(assigns(:course).id).to eq(course_2.id)
      end

      it 'should reject invalid params' do
        put :update, params: { id: course_1.id, course: {valid_params.keys.first => ''} }
        expect_update_error_with_model('course')
        expect(assigns(:course).id).to eq(course_1.id)
      end
    end

    describe "POST 'reorder'" do
      it 'should be OK with valid_array' do
        post :reorder, params: { array_of_ids: [course_2.id, course_1.id] }
        expect_reorder_success
      end
    end

    describe "DELETE 'destroy'" do
      it 'should be OK even though dependencies exist' do
        delete :destroy, params: { id: course_1.id }
        expect_archive_success_with_model('course', course_1.id, admin_courses_url)
      end

      it 'should be OK as no dependencies exist' do
        delete :destroy, params: { id: course_5.id }
        expect_delete_success_with_model('course', admin_courses_url)
      end
    end

    describe '#clone' do
      context 'clone subject course' do
        it 'should duplicate subject course' do
          post :clone, params: { id: course_1.id }

          expect(response.status).to eq(302)
          expect(response).to redirect_to(admin_courses_url)
          expect(flash[:success]).to be_present
          expect(flash[:success]).to eq('Course successfully duplicaded')
        end

        it 'should not duplicate subject course' do
          course_dup = course_1.dup
          course_dup.update(name: "#{course_1.name} copy", name_url: "#{course_1.name}_copy")
          post :clone, params: { id: course_1.id }

          expect(response.status).to eq(302)
          expect(response).to redirect_to(admin_courses_url)
          expect(flash[:error]).to be_present
          expect(flash[:error]).to eq('Course not successfully duplicaded')
        end
      end
    end

    describe '#check_accredible_group' do
      context 'check if the course has a accredible group' do
        it 'should return a valid response' do
          allow_any_instance_of(Accredible::Groups).to receive(:details).and_return(status: :ok)
          post :check_accredible_group, params: { group_id: '1234' }

          expect(response.status).to eq(200)
        end

        it 'should return a not valid response' do
          allow_any_instance_of(Accredible::Groups).to receive(:details).and_return(status: :error)
          post :check_accredible_group, params: { group_id: '1234' }

          expect(response.status).to eq(500)
        end
      end
    end
  end
end
