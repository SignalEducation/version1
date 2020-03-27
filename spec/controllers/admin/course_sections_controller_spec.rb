# == Schema Information
#
# Table name: course_sections
#
#  id                         :integer          not null, primary key
#  course_id          :integer
#  name                       :string
#  name_url                   :string
#  sorting_order              :integer
#  active                     :boolean          default(FALSE)
#  counts_towards_completion  :boolean          default(FALSE)
#  assumed_knowledge          :boolean          default(FALSE)
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  cme_count                  :integer          default(0)
#  video_count                :integer          default(0)
#  quiz_count                 :integer          default(0)
#  destroyed_at               :datetime
#  constructed_response_count :integer          default(0)
#

require 'rails_helper'

RSpec.describe Admin::CourseSectionsController, type: :controller do

  let(:content_management_user_group) { FactoryBot.create(:content_management_user_group) }
  let(:content_management_user) { FactoryBot.create(:content_management_user, user_group_id: content_management_user_group.id) }

  let!(:exam_body_1) { FactoryBot.create(:exam_body) }
  let!(:group_1) { FactoryBot.create(:group) }
  let!(:course_1)  { FactoryBot.create(:active_course,
                                               group_id: group_1.id,
                                               exam_body_id: exam_body_1.id) }
  let!(:course_section_1) { FactoryBot.create(:course_section, course_id: course_1.id) }
  let!(:course_section_2) { FactoryBot.create(:course_section, course_id: course_1.id) }

  let!(:valid_params) { FactoryBot.attributes_for(:course_section, course_id: course_1.id) }

  context 'Logged in as a content_management_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(content_management_user)
    end

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new, params: { id: course_1.id }
        expect_new_success_with_model('course_section')
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond OK with course_section_1' do
        get :edit, params: { id: course_section_1.id }
        expect_edit_success_with_model('course_section', course_section_1.id)
      end

      # optional
      it 'should respond OK with course_section_2' do
        get :edit, params: { id: course_section_2.id }
        expect_edit_success_with_model('course_section', course_section_2.id)
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, params: { course_section: valid_params }
        expect_create_success_with_model('course_section', subject.course_lesson_special_link(assigns(:course_section)))
      end

      it 'should report error for invalid params' do
        post :create, params: { course_section: {valid_params.keys.first => ''} }
        expect_create_error_with_model('course_section')
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params for course_section_1' do
        put :update, params: { id: course_section_1.id, course_section: valid_params }
        expect(flash[:success]).to eq(I18n.t('controllers.course_sections.update.flash.success'))
        expect(flash[:error]).to eq(nil)
        expect(assigns(:course_section).class).to eq(CourseSection)
        expect(response).to redirect_to(course_url(course_section_1.course))
      end

      # optional
      it 'should respond OK to valid params for course_section_2' do
        put :update, params: { id: course_section_2.id, course_section: valid_params }
        expect(flash[:success]).to eq(I18n.t('controllers.course_sections.update.flash.success'))
        expect(flash[:error]).to eq(nil)
        expect(assigns(:course_section).class).to eq(CourseSection)
        expect(response).to redirect_to(course_url(course_section_2.course))
      end

      it 'should reject invalid params' do
        put :update, params: { id: course_section_1.id, course_section: {valid_params.keys.first => ''} }
        expect_update_error_with_model('course_section')
        expect(assigns(:course_section).id).to eq(course_section_1.id)
      end
    end

    describe "POST 'reorder'" do
      it 'should be OK with valid_array' do
        post :reorder, params: { array_of_ids: [course_section_2.id, course_section_1.id] }
        expect_reorder_success
      end
    end

    describe "DELETE 'destroy'" do
      it 'should be OK even though dependencies exist' do
        delete :destroy, params: { id: course_section_1.id }
        expect_delete_success_with_model('course_section', course_url(course_section_1.course))
      end

      it 'should be OK as no dependencies exist' do
        delete :destroy, params: { id: course_section_2.id }
        expect_delete_success_with_model('course_section', course_url(course_section_2.course))
      end
    end

  end
end
