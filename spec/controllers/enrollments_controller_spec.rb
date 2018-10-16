# == Schema Information
#
# Table name: enrollments
#
#  id                         :integer          not null, primary key
#  user_id                    :integer
#  subject_course_id          :integer
#  subject_course_user_log_id :integer
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  active                     :boolean          default(FALSE)
#  exam_body_id               :integer
#  exam_date                  :date
#  expired                    :boolean          default(FALSE)
#  paused                     :boolean          default(FALSE)
#  notifications              :boolean          default(TRUE)
#  exam_sitting_id            :integer
#  computer_based_exam        :boolean          default(FALSE)
#  percentage_complete        :integer          default(0)
#

require 'rails_helper'

RSpec.describe EnrollmentsController, type: :controller do
  let!(:student_user_group ) { FactoryBot.create(:student_user_group ) }
  let!(:student_user) { FactoryBot.create(:student_user, user_group_id: student_user_group.id) }
  let!(:student_access) { FactoryBot.create(:valid_free_trial_student_access, user_id: student_user.id) }

  let!(:exam_body_1) { FactoryBot.create(:exam_body) }
  let!(:group_1) { FactoryBot.create(:group) }
  let!(:subject_course_1)  { FactoryBot.create(:active_subject_course, group_id: group_1.id, exam_body_id: exam_body_1.id) }
  let!(:subject_course_2)  { FactoryBot.create(:active_subject_course, group_id: group_1.id, computer_based: true, exam_body_id: exam_body_1.id) }

  let!(:exam_sitting_1) { FactoryBot.create(:exam_sitting, subject_course_id: subject_course_1.id, exam_body_id: exam_body_1.id) }
  let!(:exam_sitting_2) { FactoryBot.create(:exam_sitting, subject_course_id: subject_course_1.id, exam_body_id: exam_body_1.id) }
  let!(:exam_sitting_3) { FactoryBot.create(:computer_based_exam_sitting, subject_course_id: subject_course_2.id, exam_body_id: exam_body_1.id) }

  let!(:enrollment_1) { FactoryBot.create(:enrollment, user_id: student_user.id, subject_course_id: subject_course_1.id, exam_body_id: exam_body_1.id) }
  let!(:scul_1) { FactoryBot.create(:subject_course_user_log, user_id: student_user.id, subject_course_id: subject_course_1.id, percentage_complete: 1) }
  let!(:enrollment_2) { FactoryBot.create(:enrollment, user_id: student_user.id, subject_course_id: subject_course_1.id, exam_body_id: exam_body_1.id) }

  let!(:valid_params) { {enrollment: {subject_course_id: subject_course_1.id, exam_sitting_id: exam_sitting_1.id}} }
  let!(:custom_date_params) { {enrollment: {subject_course_id: subject_course_1.id, exam_sitting_id: exam_sitting_1.id, exam_date: '2019-12-01'}} }
  let!(:custom_old_log_params) { {enrollment: {subject_course_id: subject_course_1.id, exam_sitting_id: exam_sitting_1.id,
                                               subject_course_user_log_id: scul_1.id, exam_date: '2019-12-01'}} }
  let!(:invalid_params) { {enrollment: {subject_course_id: nil, exam_date: exam_sitting_1.date, custom_exam_date: ''}} }


  context 'Logged in as a student_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(student_user)
    end

    describe "POST 'create'" do
      it 'should report OK for valid_params' do
        post :create, valid_params
        expect_create_success_with_model('enrollment', library_course_url(subject_course_1.parent.name_url, subject_course_1.name_url))
      end

      it 'should report OK for params_with_custom_date' do
        post :create, custom_date_params
        expect_create_success_with_model('enrollment', library_course_url(subject_course_1.parent.name_url, subject_course_1.name_url))
      end

      it 'should report OK for attaching previous enrollment scul_id' do
        post :create, custom_old_log_params
        expect_create_success_with_model('enrollment', library_course_url(subject_course_1.parent.name_url, subject_course_1.name_url))
      end

      it 'should fail for invalid_params' do
        post :create, invalid_params
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to eq(I18n.t('controllers.enrollments.create.flash.error'))
        expect(response.status).to eq(302)
        expect(response).to redirect_to(library_url)
      end

    end

    describe "GET 'edit/1'" do
      it 'should respond OK with enrollment_1' do
        get :edit, id: enrollment_1.id
        expect_edit_success_with_model('enrollment', enrollment_1.id)
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK with new params' do
        put :update, id: enrollment_1.id, enrollment: {notifications: false}
        expect(flash[:error]).to be_nil
        expect(flash[:success]).to eq(I18n.t('controllers.enrollments.update.flash.success'))
        expect(response.status).to eq(302)
        expect(response).to redirect_to(account_url(anchor: :enrollments))
      end
    end


  end
end
