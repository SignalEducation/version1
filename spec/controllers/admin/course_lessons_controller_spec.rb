# == Schema Information
#
# Table name: course_lessons
#
#  id                         :integer          not null, primary key
#  name                       :string
#  name_url                   :string
#  description                :text
#  sorting_order              :integer
#  estimated_time_in_seconds  :integer
#  active                     :boolean          default(FALSE), not null
#  created_at                 :datetime
#  updated_at                 :datetime
#  cme_count                  :integer          default(0)
#  seo_description            :string
#  seo_no_index               :boolean          default(FALSE)
#  destroyed_at               :datetime
#  number_of_questions        :integer          default(0)
#  course_id          :integer
#  video_duration             :float            default(0.0)
#  video_count                :integer          default(0)
#  quiz_count                 :integer          default(0)
#  highlight_colour           :string
#  tuition                    :boolean          default(FALSE)
#  test                       :boolean          default(FALSE)
#  revision                   :boolean          default(FALSE)
#  course_section_id          :integer
#  constructed_response_count :integer          default(0)
#

require 'rails_helper'

describe Admin::CourseLessonsController, type: :controller do

  let(:content_management_user_group) { FactoryBot.create(:content_management_user_group) }
  let(:content_management_user) { FactoryBot.create(:content_management_user, user_group_id: content_management_user_group.id) }

  let!(:exam_body_1) { FactoryBot.create(:exam_body) }
  let!(:group_1) { FactoryBot.create(:group) }
  let!(:course_1)  { FactoryBot.create(:active_course,
                                               group_id: group_1.id,
                                               exam_body_id: exam_body_1.id) }
  let!(:course_section_1) { FactoryBot.create(:course_section, course_id: course_1.id) }
  let!(:course_lesson_1) { FactoryBot.create(:active_course_lesson, course_id: course_1.id, course_section_id: course_section_1.id) }
  let!(:course_lesson_2) { FactoryBot.create(:active_course_lesson, course_id: course_1.id, course_section_id: course_section_1.id) }

  let!(:valid_params) { FactoryBot.attributes_for(:course_lesson, course_section_id: course_section_1.id, course_id: course_1.id) }

  context 'Logged in as a content_management_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(content_management_user)
    end

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new, params: { id: course_1.id, course_section_id: course_section_1.id }
        expect_new_success_with_model('course_lesson')
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond OK with course_lesson_1' do
        get :edit, params: { id: course_1.id, course_section_id: course_section_1.id, course_lesson_id: course_lesson_1.id }
        expect_edit_success_with_model('course_lesson', course_lesson_1.id)
      end

      # optional
      it 'should respond OK with course_lesson_2' do
        get :edit, params: { id: course_1.id, course_section_id: course_section_1.id, course_lesson_id: course_lesson_2.id }
        expect_edit_success_with_model('course_lesson', course_lesson_2.id)
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, params: { course_lesson: valid_params }
        expect_create_success_with_model('course_lesson', admin_course_url(valid_params[:course_id]))
      end

      it 'should report error for invalid params' do
        post :create, params: { course_lesson: {valid_params.keys.first => ''} }
        expect_create_error_with_model('course_lesson')
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params for course_lesson_1' do
        put :update, params: { id: course_lesson_1.id, course_lesson: {name: 'ABC'} }
        expect(flash[:success]).to eq(I18n.t('controllers.course_lessons.update.flash.success'))
        expect(flash[:error]).to eq(nil)
        expect(assigns(:course_lesson).class).to eq(CourseLesson)
        expect(response).to redirect_to(admin_course_url(course_lesson_1.course))
      end

      # optional
      it 'should respond OK to valid params for course_lesson_2' do
        put :update, params: { id: course_lesson_2.id, course_lesson: {name: 'ABC'} }
        expect(flash[:success]).to eq(I18n.t('controllers.course_lessons.update.flash.success'))
        expect(flash[:error]).to eq(nil)
        expect(assigns(:course_lesson).class).to eq(CourseLesson)
        expect(response).to redirect_to(admin_course_url(course_lesson_2.course))
      end

      it 'should reject invalid params' do
        put :update, params: { id: course_lesson_1.id, course_lesson: {valid_params.keys.first => ''} }
        expect_update_error_with_model('course_lesson')
        expect(assigns(:course_lesson).id).to eq(course_lesson_1.id)
      end
    end

    describe "POST 'reorder'" do
      it 'should be OK with valid_array' do
        post :reorder, params: { array_of_ids: [course_lesson_2.id, course_lesson_1.id] }
        expect_reorder_success
      end
    end

    describe "DELETE 'destroy'" do
      it 'should be OK even though dependencies exist' do
        delete :destroy, params: { id: course_lesson_1.id }
        expect_archive_success_with_model('course_lesson', course_lesson_1.id, admin_course_url(course_lesson_1.course))
      end

      it 'should be OK as no dependencies exist' do
        delete :destroy, params: { id: course_lesson_2.id }
        expect_archive_success_with_model('course_lesson', course_lesson_2.id, admin_course_url(course_lesson_2.course))
      end
    end
  end
end
