# == Schema Information
#
# Table name: course_sections
#
#  id                         :integer          not null, primary key
#  subject_course_id          :integer
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

RSpec.describe CourseSectionsController, type: :controller do

  let(:content_management_user_group) { FactoryBot.create(:content_management_user_group) }
  let(:content_management_user) { FactoryBot.create(:content_management_user, user_group_id: content_management_user_group.id) }
  let!(:content_management_user_student_access) { FactoryBot.create(:complimentary_student_access, user_id: content_management_user.id) }
  let!(:group_1) { FactoryBot.create(:group) }
  let!(:subject_course_1)  { FactoryBot.create(:active_subject_course,
                                               group_id: group_1.id,
                                               exam_body_id: 1) }
  let!(:course_section_1) { FactoryBot.create(:course_section, subject_course_id: subject_course_1.id) }
  let!(:course_section_2) { FactoryBot.create(:course_section, subject_course_id: subject_course_1.id) }

  let!(:valid_params) { FactoryBot.attributes_for(:course_section, subject_course_id: subject_course_1.id) }

  context 'Logged in as a content_management_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(content_management_user)
    end

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new, subject_course_name_url: subject_course_1.name_url
        expect_new_success_with_model('course_module')
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond OK with course_module_1' do
        get :edit, id: course_module_1.id
        expect_edit_success_with_model('course_module', course_module_1.id)
      end

      # optional
      it 'should respond OK with course_module_2' do
        get :edit, id: course_module_2.id
        expect_edit_success_with_model('course_module', course_module_2.id)
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, course_module: valid_params
        expect_create_success_with_model('course_module', subject.course_module_special_link(assigns(:course_module)))
      end

      it 'should report error for invalid params' do
        post :create, course_module: {valid_params.keys.first => ''}
        expect_create_error_with_model('course_module')
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params for course_module_1' do
        put :update, id: course_module_1.id, course_module: {name: 'ABC'}
        expect(flash[:success]).to eq(I18n.t('controllers.course_modules.update.flash.success'))
        expect(flash[:error]).to eq(nil)
        expect(assigns(:course_module).class).to eq(CourseModule)
        expect(response).to redirect_to(subject_course_url(course_module_1.subject_course))
      end

      # optional
      it 'should respond OK to valid params for course_module_2' do
        put :update, id: course_module_2.id, course_module: {name: 'ABC'}
        expect(flash[:success]).to eq(I18n.t('controllers.course_modules.update.flash.success'))
        expect(flash[:error]).to eq(nil)
        expect(assigns(:course_module).class).to eq(CourseModule)
        expect(response).to redirect_to(subject_course_url(course_module_2.subject_course))
      end

      it 'should reject invalid params' do
        put :update, id: course_module_1.id, course_module: {valid_params.keys.first => ''}
        expect_update_error_with_model('course_module')
        expect(assigns(:course_module).id).to eq(course_module_1.id)
      end
    end

    describe "POST 'reorder'" do
      it 'should be OK with valid_array' do
        post :reorder, array_of_ids: [course_module_2.id, course_module_1.id]
        expect_reorder_success
      end
    end

    describe "DELETE 'destroy'" do
      it 'should be OK even though dependencies exist' do
        delete :destroy, id: course_module_1.id
        expect_archive_success_with_model('course_module', course_module_1.id, subject_course_url(course_module_1.subject_course))
      end

      it 'should be OK as no dependencies exist' do
        delete :destroy, id: course_module_2.id
        expect_archive_success_with_model('course_module', course_module_2.id, subject_course_url(course_module_2.subject_course))
      end
    end

  end
end
