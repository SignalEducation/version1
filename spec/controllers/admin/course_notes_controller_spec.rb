# == Schema Information
#
# Table name: course_notes
#
#  id                       :integer          not null, primary key
#  course_step_id :integer
#  name                     :string
#  web_url                  :string
#  created_at               :datetime
#  updated_at               :datetime
#  upload_file_name         :string
#  upload_content_type      :string
#  upload_file_size         :integer
#  upload_updated_at        :datetime
#  destroyed_at             :datetime
#

require 'rails_helper'
require 'support/course_content'

describe Admin::CourseNotesController, type: :controller do

  let(:content_management_user_group) { FactoryBot.create(:content_management_user_group) }
  let(:content_management_user) { FactoryBot.create(:content_management_user, user_group_id: content_management_user_group.id) }

  let!(:group) { FactoryBot.create(:group) }
  let!(:exam_body) { FactoryBot.create(:exam_body) }
  let!(:course)  { FactoryBot.create(:active_course, group_id: group.id, exam_body_id: exam_body.id) }
  let!(:course_section) { FactoryBot.create(:course_section,
                                            course: course) }
  let!(:course_lesson) { FactoryBot.create(:active_course_lesson,
                                           course_section: course_section,
                                           course: course) }
  let!(:course_step) { FactoryBot.create(:course_step, :cme_video,
                                                   course_lesson: course_lesson) }
  let!(:course_note_1) { FactoryBot.create(:course_note, course_step_id: course_step.id) }
  let!(:course_note_2) { FactoryBot.create(:course_note, course_step_id: course_step.id) }

  let!(:valid_params) { FactoryBot.attributes_for(:course_note, course_step_id: course_step.id) }

  context 'Logged in as a content_management_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(content_management_user)
    end

    describe "GET 'index'" do
      it 'should respond OK' do
        get :index, params: { course_step_id: course_step.id }


        expect_index_success_with_model('course_notes', 1)
      end
    end

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new, params: { course_step_id: course_step.id }
        expect_new_success_with_model('course_note')
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond OK with course_step' do
        get :edit, params: { course_step_id: course_step.id, id: course_note_1.id }
        expect_edit_success_with_model('course_note', course_note_1.id)
      end

      # optional
      it 'should respond OK with course_step' do
        get :edit, params: { course_step_id: course_step.id, id: course_note_1.id }
        expect_edit_success_with_model('course_note', course_note_1.id)
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, params: { course_step_id: course_step.id, course_note: valid_params }
        expect_create_success_with_model('course_note', edit_admin_course_step_url(course_step.id))
      end
    end

    describe "POST 'create' 2" do
      it 'should report error for invalid params' do
        post :create, params: { course_step_id: course_step.id, course_note: {valid_params.keys.first => ''} }
        expect_create_error_with_model('course_note')
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params for course_note_1' do
        put :update, params: { course_step_id: course_step.id, id: course_note_1.id, course_note: {name: 'ABC'} }
        expect_update_success_with_model('course_note', edit_admin_course_step_url(course_step.id))
      end

      it 'should reject invalid params' do
        put :update, params: { course_step_id: course_step.id, id: course_note_1.id, course_note: {valid_params.keys.first => ''} }
        expect_update_error_with_model('course_note')
        expect(assigns(:course_note).id).to eq(course_note_1.id)
      end
    end

    describe "DELETE 'destroy'" do
      it 'should be OK even though dependencies exist' do
        delete :destroy, params: { course_step_id: course_step.id, id: course_note_1.id }
        expect_archive_success_with_model('course_note', course_note_1.id, edit_admin_course_step_url(course_step.id))
      end
    end

  end

end
