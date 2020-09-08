# == Schema Information
#
# Table name: enrollments
#
#  id                         :integer          not null, primary key
#  user_id                    :integer
#  course_id          :integer
#  course_log_id :integer
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
  let!(:basic_student) { FactoryBot.create(:basic_student, user_group_id: student_user_group.id) }

  let!(:exam_body_1) { FactoryBot.create(:exam_body) }
  let!(:group_1) { FactoryBot.create(:group, exam_body_id: exam_body_1.id) }
  let!(:course_1)  { FactoryBot.create(:active_course,
                                               group_id: group_1.id,
                                               exam_body_id: exam_body_1.id) }
  let!(:course_2)  { FactoryBot.create(:active_course,
                                               group_id: group_1.id,
                                               computer_based: true,
                                               exam_body_id: exam_body_1.id) }
  let!(:standard_exam_sitting)  { FactoryBot.create(:standard_exam_sitting,
                                                    course_id: course_1.id,
                                                    exam_body_id: exam_body_1.id) }
  let!(:computer_based_exam_sitting)  { FactoryBot.create(:computer_based_exam_sitting,
                                                          course_id: course_2.id,
                                                          exam_body_id: exam_body_1.id) }

  let!(:scul_1) { FactoryBot.create(:course_log, user_id: basic_student.id, course_id: course_1.id, percentage_complete: 1) }
  let!(:enrollment_1) { FactoryBot.create(:enrollment, user_id: basic_student.id, course_id: course_1.id, course_log_id: scul_1.id, exam_body_id: exam_body_1.id) }

  let!(:scul_2) { FactoryBot.create(:course_log, user_id: basic_student.id, course_id: course_2.id, percentage_complete: 10) }
  let!(:enrollment_2) { FactoryBot.create(:enrollment, user_id: basic_student.id, course_id: course_2.id, course_log_id: scul_2.id, exam_body_id: exam_body_1.id) }

  let!(:valid_params) { FactoryBot.attributes_for(:enrollment, user_id: basic_student.id, course_id: course_1.id, course_log_id: nil, exam_sitting_id: standard_exam_sitting.id) }
  let!(:custom_date_params) { FactoryBot.attributes_for(:enrollment, user_id: basic_student.id, course_id: course_2.id, course_log_id: nil, exam_sitting_id: computer_based_exam_sitting.id, exam_date: Time.zone.today + 1.year) }
  let!(:existing_log_params) { FactoryBot.attributes_for(:enrollment, user_id: basic_student.id, course_id: course_2.id, course_log_id: scul_2.id, exam_sitting_id: computer_based_exam_sitting.id, exam_date: Time.zone.today + 1.year) }
  let!(:invalid_params) { FactoryBot.attributes_for(:enrollment, user_id: basic_student.id, course_id: nil, course_log_id: scul_2.id, exam_sitting_id: nil, exam_date: Time.zone.today + 1.year) }

  context 'Logged in as a basic_student: ' do
    before(:each) do
      activate_authlogic
      UserSession.create!(basic_student)
    end

    describe "POST 'create'" do
      it 'should report OK for valid_params' do
        post :create, params: {enrollment: valid_params}
        expect(flash[:error]).to be_nil
        expect(flash[:success]).to eq("Thank you. You have successfully enrolled in #{course_1.name}")
        expect(response.status).to eq(204)
      end

      it 'should report OK for params_with_custom_date' do
        post :create, params: { enrollment: custom_date_params }
        expect(flash[:error]).to be_nil
        expect(flash[:success]).to eq("Thank you. You have successfully enrolled in #{course_2.name}")
        expect(response.status).to eq(204)
      end

      it 'should report OK for attaching previous enrollment scul_id' do
        post :create, params: { enrollment: existing_log_params }
        expect(flash[:error]).to be_nil
        expect(flash[:success]).to eq("Thank you. You have successfully enrolled in #{course_2.name}")
        expect(response.status).to eq(204)
      end

      it 'should fail for invalid_params' do
        post :create, params: { enrollment: invalid_params }
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to eq(I18n.t('controllers.enrollments.create.flash.error'))
        expect(response.status).to eq(302)
        expect(response).to redirect_to(library_url)
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond OK with enrollment_1' do
        get :edit, params: { id: enrollment_1.id }
        expect_edit_success_with_model('enrollment', enrollment_1.id)
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK with new params' do
        put :update, params: { id: enrollment_1.id, enrollment: {notifications: false} }
        expect(flash[:error]).to be_nil
        expect(flash[:success]).to eq(I18n.t('controllers.enrollments.update.flash.success'))
        expect(response.status).to eq(302)
        expect(response).to redirect_to(account_url(anchor: :enrollments))
      end
    end


  end
end
