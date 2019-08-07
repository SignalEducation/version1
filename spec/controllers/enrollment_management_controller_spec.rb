require 'rails_helper'

RSpec.describe EnrollmentManagementController, :type => :controller do

  let(:user_management_user_group) { FactoryBot.create(:user_management_user_group) }
  let(:user_management_user) { FactoryBot.create(:user_management_user,
                                                 user_group_id: user_management_user_group.id) }
  let!(:student_user_group ) { FactoryBot.create(:student_user_group ) }
  let!(:basic_student) { FactoryBot.create(:basic_student, user_group_id: student_user_group.id) }

  let!(:exam_body_1) { FactoryBot.create(:exam_body) }
  let!(:group_1) { FactoryBot.create(:group, exam_body_id: exam_body_1.id) }
  let!(:subject_course_1)  { FactoryBot.create(:active_subject_course,
                                               group_id: group_1.id,
                                               exam_body_id: exam_body_1.id) }
  let!(:subject_course_2)  { FactoryBot.create(:active_subject_course,
                                               group_id: group_1.id,
                                               computer_based: true,
                                               exam_body_id: exam_body_1.id) }
  let!(:standard_exam_sitting)  { FactoryBot.create(:standard_exam_sitting,
                                                    subject_course_id: subject_course_1.id,
                                                    exam_body_id: exam_body_1.id) }
  let!(:computer_based_exam_sitting)  { FactoryBot.create(:computer_based_exam_sitting,
                                                          subject_course_id: subject_course_2.id,
                                                          exam_body_id: exam_body_1.id) }

  let!(:scul_1) { FactoryBot.create(:subject_course_user_log, user_id: basic_student.id, subject_course_id: subject_course_1.id, percentage_complete: 1) }
  let!(:enrollment_1) { FactoryBot.create(:enrollment, user_id: basic_student.id, subject_course_id: subject_course_1.id, subject_course_user_log_id: scul_1.id, exam_body_id: exam_body_1.id) }

  let!(:scul_2) { FactoryBot.create(:subject_course_user_log, user_id: basic_student.id, subject_course_id: subject_course_2.id, percentage_complete: 10) }
  let!(:enrollment_2) { FactoryBot.create(:enrollment, user_id: basic_student.id, subject_course_id: subject_course_2.id, subject_course_user_log_id: scul_2.id, exam_body_id: exam_body_1.id) }

  let!(:valid_params) { FactoryBot.attributes_for(:enrollment, user_id: basic_student.id, subject_course_id: subject_course_1.id, subject_course_user_log_id: nil, exam_sitting_id: standard_exam_sitting.id) }

  context 'Logged in as a user_management_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(user_management_user)
    end

    describe 'GET index' do
      it 'should respond OK' do
        get :index
        expect_index_success_with_model('enrollments', 2)
      end
    end

    describe 'GET edit' do
      it 'should respond OK with enrollment_1' do
        get :edit, params: { id: enrollment_1.id }
        expect_edit_success_with_model('enrollment', enrollment_1.id)
      end
    end

    describe 'PUT update' do
      it 'should respond OK to valid params for enrollment_1' do
        put :update, params: { id: enrollment_1.id, enrollment: valid_params }
        expect(flash[:error]).to be_nil
        expect(flash[:success]).to eq(I18n.t('controllers.enrollments.admin_update.flash.success'))
        expect(response.status).to eq(302)
        expect(response).to redirect_to(user_activity_url(enrollment_1.user))
      end
    end

    describe 'GET show' do
      it 'should see enrollment_1' do
        get :show,params: {  id: enrollment_1.id }
        expect_show_success_with_model('enrollment', enrollment_1.id)
      end
    end

    describe 'POST create_new_scul' do
      it 'should respond OK to enrollment_1 id' do
        post :create_new_scul, params: { id: enrollment_1.id }
        expect(flash[:success]).to eq(I18n.t('controllers.enrollments.admin_create_new_scul.flash.success'))
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(302)
        expect(response).to redirect_to(enrollment_management_url(enrollment_1))

      end
    end

  end


end