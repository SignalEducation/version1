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
#

require 'rails_helper'
require 'support/users_and_groups_setup'

RSpec.describe EnrollmentsController, type: :controller do

  include_context 'users_and_groups_setup'

  let!(:enrollment_1) { FactoryGirl.create(:enrollment, subject_course_id: course_1.id) }
  let!(:enrollment_2) { FactoryGirl.create(:enrollment, subject_course_id: course_1.id) }
  let!(:exam_sitting_1) { FactoryGirl.create(:exam_sitting, subject_course_id: course_1.id) }
  let!(:exam_sitting_2) { FactoryGirl.create(:exam_sitting, subject_course_id: course_1.id) }
  let!(:course_1) { FactoryGirl.create(:subject_course) }
  let!(:registered_params) { {enrollment: [subject_course_id: 1, student_number: '124324554667'], registered: 1, exam_date: '2016-12-01', custom_exam_date: ''} }
  let!(:registered_params_with_custom_date) { {enrollment: [subject_course_id: 1, student_number: '124324554667'], registered: 1, exam_date: '', custom_exam_date: '2016-12-01'} }
  let!(:non_registered_params) { {enrollment: [subject_course_id: 1, student_number: nil], registered: 0, exam_date: nil, custom_exam_date: ''} }
  let!(:no_exam_body_params) { {enrollment: [subject_course_id: 1, student_number: nil], registered: 0, exam_date: nil, custom_exam_date: ''} }

  context 'Not logged in: ' do

    describe "GET 'edit/1'" do
      it 'should redirect to sign_in' do
        get :edit, id: 1
        expect_bounce_as_not_signed_in
      end
    end

    describe "POST 'create'" do
      xit 'should redirect to sign_in' do
        post :create, enrollment: valid_params
        expect_bounce_as_not_signed_in
      end
    end

    describe "PUT 'update/1'" do
      xit 'should redirect to sign_in' do
        put :update, id: 1, enrollment: valid_params
        expect_bounce_as_not_signed_in
      end
    end

    describe "PUT 'create_with_order'" do
      xit 'should redirect to sign_in' do
        get :create_with_order
        expect_bounce_as_not_signed_in
      end
    end

    describe "PUT 'basic_create'" do
      xit 'should redirect to sign_in' do
        get :basic_create, subject_course_name_url: course_1.name_url
        expect_bounce_as_not_signed_in
      end
    end

    describe "PUT 'pause'" do
      it 'should redirect to sign_in' do
        post :pause, enrollment_id: enrollment_1.id
        expect_bounce_as_not_signed_in
      end
    end

    describe "PUT 'activate'" do
      it 'should redirect to sign_in' do
        post :activate, enrollment_id: enrollment_2.id
        expect_bounce_as_not_signed_in
      end
    end

  end

  context 'Logged in as a individual_student_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(individual_student_user)
    end

    describe "GET 'edit/1'" do
      it 'should respond OK with enrollment_1' do
        get :edit, id: enrollment_1.id
        expect_edit_success_with_model('enrollment', enrollment_1.id)
      end
    end

    describe "POST 'create'" do
      xit 'should report OK for registered_params' do
        post :create, params: registered_params
        expect_create_success_with_model('enrollment', course_special_link(course_1.first_active_cme))
      end

      xit 'should report OK for registered_params_with_custom_date' do
        post :create, enrollment: registered_params_with_custom_date
        expect_create_success_with_model('enrollment', course_special_link(course_1.first_active_cme))
      end

      xit 'should report OK for non_registered_params' do
        post :create, enrollment: non_registered_params
        expect_create_success_with_model('enrollment', course_special_link(course_1.first_active_cme))
      end

    end

    describe "PUT 'update/1'" do
      xit 'should redirect to sign_in' do
        put :update, id: 1, params: registered_params
        expect_bounce_as_not_signed_in
      end


      xit 'should redirect to sign_in' do
        put :update, id: 1, params: registered_params_with_custom_date
        expect_bounce_as_not_signed_in
      end
    end

    describe "PUT 'create_with_order'" do
      xit 'should redirect to sign_in' do
        get :create_with_order
        expect_bounce_as_not_signed_in
      end
    end

    describe "PUT 'basic_create'" do
      xit 'should report OK for no_exam_body_params' do
        get :basic_create, enrollment: no_exam_body_params
        expect_bounce_as_not_signed_in
      end
    end

    describe "PUT 'pause'" do
      xit 'should redirect to sign_in' do
        post :pause, enrollment_id: enrollment_1.id
        expect_bounce_as_not_signed_in
      end
    end

    describe "PUT 'activate'" do
      xit 'should redirect to sign_in' do
        post :activate, enrollment_id: enrollment_2.id
        expect_bounce_as_not_signed_in
      end
    end

  end

  context 'Logged in as a complimentary_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(comp_user)
    end

    describe "GET 'edit/1'" do
      it 'should respond OK with enrollment_1' do
        get :edit, id: enrollment_1.id
        expect_edit_success_with_model('enrollment', enrollment_1.id)
      end
    end

    describe "POST 'create'" do
      xit 'should report OK for registered_params' do
        post :create, params: registered_params
        expect_create_success_with_model('enrollment', course_special_link(course_1.first_active_cme))
      end

      xit 'should report OK for registered_params_with_custom_date' do
        post :create, enrollment: registered_params_with_custom_date
        expect_create_success_with_model('enrollment', course_special_link(course_1.first_active_cme))
      end

      xit 'should report OK for non_registered_params' do
        post :create, enrollment: non_registered_params
        expect_create_success_with_model('enrollment', course_special_link(course_1.first_active_cme))
      end

    end

    describe "PUT 'update/1'" do
      xit 'should redirect to sign_in' do
        put :update, id: 1, params: registered_params
        expect_bounce_as_not_signed_in
      end


      xit 'should redirect to sign_in' do
        put :update, id: 1, params: registered_params_with_custom_date
        expect_bounce_as_not_signed_in
      end
    end

    describe "PUT 'create_with_order'" do
      xit 'should redirect to sign_in' do
        get :create_with_order
        expect_bounce_as_not_signed_in
      end
    end

    describe "PUT 'basic_create'" do
      xit 'should report OK for no_exam_body_params' do
        get :basic_create, enrollment: no_exam_body_params
        expect_bounce_as_not_signed_in
      end
    end

    describe "PUT 'pause'" do
      xit 'should redirect to sign_in' do
        post :pause, enrollment_id: enrollment_1.id
        expect_bounce_as_not_signed_in
      end
    end

    describe "PUT 'activate'" do
      xit 'should redirect to sign_in' do
        post :activate, enrollment_id: enrollment_2.id
        expect_bounce_as_not_signed_in
      end
    end

  end

  context 'Logged in as a tutor_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(tutor_user)
    end

    describe "GET 'edit/1'" do
      it 'should respond OK with enrollment_1' do
        get :edit, id: enrollment_1.id
        expect_edit_success_with_model('enrollment', enrollment_1.id)
      end
    end

    describe "POST 'create'" do
      xit 'should report OK for registered_params' do
        post :create, params: registered_params
        expect_create_success_with_model('enrollment', course_special_link(course_1.first_active_cme))
      end

      xit 'should report OK for registered_params_with_custom_date' do
        post :create, enrollment: registered_params_with_custom_date
        expect_create_success_with_model('enrollment', course_special_link(course_1.first_active_cme))
      end

      xit 'should report OK for non_registered_params' do
        post :create, enrollment: non_registered_params
        expect_create_success_with_model('enrollment', course_special_link(course_1.first_active_cme))
      end

    end

    describe "PUT 'update/1'" do
      xit 'should redirect to sign_in' do
        put :update, id: 1, params: registered_params
        expect_bounce_as_not_signed_in
      end


      xit 'should redirect to sign_in' do
        put :update, id: 1, params: registered_params_with_custom_date
        expect_bounce_as_not_signed_in
      end
    end

    describe "PUT 'create_with_order'" do
      xit 'should redirect to sign_in' do
        get :create_with_order
        expect_bounce_as_not_signed_in
      end
    end

    describe "PUT 'basic_create'" do
      xit 'should report OK for no_exam_body_params' do
        get :basic_create, enrollment: no_exam_body_params
        expect_bounce_as_not_signed_in
      end
    end

    describe "PUT 'pause'" do
      xit 'should redirect to sign_in' do
        post :pause, enrollment_id: enrollment_1.id
        expect_bounce_as_not_signed_in
      end
    end

    describe "PUT 'activate'" do
      xit 'should redirect to sign_in' do
        post :activate, enrollment_id: enrollment_2.id
        expect_bounce_as_not_signed_in
      end
    end

  end

  context 'Logged in as a blogger_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(blogger_user)
    end

    describe "GET 'edit/1'" do
      it 'should respond OK with enrollment_1' do
        get :edit, id: enrollment_1.id
        expect_edit_success_with_model('enrollment', enrollment_1.id)
      end
    end

    describe "POST 'create'" do
      xit 'should report OK for registered_params' do
        post :create, params: registered_params
        expect_create_success_with_model('enrollment', course_special_link(course_1.first_active_cme))
      end

      xit 'should report OK for registered_params_with_custom_date' do
        post :create, enrollment: registered_params_with_custom_date
        expect_create_success_with_model('enrollment', course_special_link(course_1.first_active_cme))
      end

      xit 'should report OK for non_registered_params' do
        post :create, enrollment: non_registered_params
        expect_create_success_with_model('enrollment', course_special_link(course_1.first_active_cme))
      end

    end

    describe "PUT 'update/1'" do
      xit 'should redirect to sign_in' do
        put :update, id: 1, params: registered_params
        expect_bounce_as_not_signed_in
      end


      xit 'should redirect to sign_in' do
        put :update, id: 1, params: registered_params_with_custom_date
        expect_bounce_as_not_signed_in
      end
    end

    describe "PUT 'create_with_order'" do
      xit 'should redirect to sign_in' do
        get :create_with_order
        expect_bounce_as_not_signed_in
      end
    end

    describe "PUT 'basic_create'" do
      xit 'should report OK for no_exam_body_params' do
        get :basic_create, enrollment: no_exam_body_params
        expect_bounce_as_not_signed_in
      end
    end

    describe "PUT 'pause'" do
      xit 'should redirect to sign_in' do
        post :pause, enrollment_id: enrollment_1.id
        expect_bounce_as_not_signed_in
      end
    end

    describe "PUT 'activate'" do
      xit 'should redirect to sign_in' do
        post :activate, enrollment_id: enrollment_2.id
        expect_bounce_as_not_signed_in
      end
    end

  end

  context 'Logged in as a content_manager_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(content_manager_user)
    end

    describe "GET 'edit/1'" do
      it 'should respond OK with enrollment_1' do
        get :edit, id: enrollment_1.id
        expect_edit_success_with_model('enrollment', enrollment_1.id)
      end
    end

    describe "POST 'create'" do
      xit 'should report OK for registered_params' do
        post :create, params: registered_params
        expect_create_success_with_model('enrollment', course_special_link(course_1.first_active_cme))
      end

      xit 'should report OK for registered_params_with_custom_date' do
        post :create, enrollment: registered_params_with_custom_date
        expect_create_success_with_model('enrollment', course_special_link(course_1.first_active_cme))
      end

      xit 'should report OK for non_registered_params' do
        post :create, enrollment: non_registered_params
        expect_create_success_with_model('enrollment', course_special_link(course_1.first_active_cme))
      end

    end

    describe "PUT 'update/1'" do
      xit 'should redirect to sign_in' do
        put :update, id: 1, params: registered_params
        expect_bounce_as_not_signed_in
      end


      xit 'should redirect to sign_in' do
        put :update, id: 1, params: registered_params_with_custom_date
        expect_bounce_as_not_signed_in
      end
    end

    describe "PUT 'create_with_order'" do
      xit 'should redirect to sign_in' do
        get :create_with_order
        expect_bounce_as_not_signed_in
      end
    end

    describe "PUT 'basic_create'" do
      xit 'should report OK for no_exam_body_params' do
        get :basic_create, enrollment: no_exam_body_params
        expect_bounce_as_not_signed_in
      end
    end

    describe "PUT 'pause'" do
      xit 'should redirect to sign_in' do
        post :pause, enrollment_id: enrollment_1.id
        expect_bounce_as_not_signed_in
      end
    end

    describe "PUT 'activate'" do
      xit 'should redirect to sign_in' do
        post :activate, enrollment_id: enrollment_2.id
        expect_bounce_as_not_signed_in
      end
    end

  end

  context 'Logged in as a customer_support_manager_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(customer_support_manager_user)
    end

    describe "GET 'edit/1'" do
      it 'should respond OK with enrollment_1' do
        get :edit, id: enrollment_1.id
        expect_edit_success_with_model('enrollment', enrollment_1.id)
      end
    end

    describe "POST 'create'" do
      xit 'should report OK for registered_params' do
        post :create, params: registered_params
        expect_create_success_with_model('enrollment', course_special_link(course_1.first_active_cme))
      end

      xit 'should report OK for registered_params_with_custom_date' do
        post :create, enrollment: registered_params_with_custom_date
        expect_create_success_with_model('enrollment', course_special_link(course_1.first_active_cme))
      end

      xit 'should report OK for non_registered_params' do
        post :create, enrollment: non_registered_params
        expect_create_success_with_model('enrollment', course_special_link(course_1.first_active_cme))
      end

    end

    describe "PUT 'update/1'" do
      xit 'should redirect to sign_in' do
        put :update, id: 1, params: registered_params
        expect_bounce_as_not_signed_in
      end


      xit 'should redirect to sign_in' do
        put :update, id: 1, params: registered_params_with_custom_date
        expect_bounce_as_not_signed_in
      end
    end

    describe "PUT 'create_with_order'" do
      xit 'should redirect to sign_in' do
        get :create_with_order
        expect_bounce_as_not_signed_in
      end
    end

    describe "PUT 'basic_create'" do
      xit 'should report OK for no_exam_body_params' do
        get :basic_create, enrollment: no_exam_body_params
        expect_bounce_as_not_signed_in
      end
    end

    describe "PUT 'pause'" do
      xit 'should redirect to sign_in' do
        post :pause, enrollment_id: enrollment_1.id
        expect_bounce_as_not_signed_in
      end
    end

    describe "PUT 'activate'" do
      xit 'should redirect to sign_in' do
        post :activate, enrollment_id: enrollment_2.id
        expect_bounce_as_not_signed_in
      end
    end

  end

  context 'Logged in as a marketing_manager_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(marketing_manager_user)
    end

    describe "GET 'edit/1'" do
      it 'should respond OK with enrollment_1' do
        get :edit, id: enrollment_1.id
        expect_edit_success_with_model('enrollment', enrollment_1.id)
      end
    end

    describe "POST 'create'" do
      xit 'should report OK for registered_params' do
        post :create, params: registered_params
        expect_create_success_with_model('enrollment', course_special_link(course_1.first_active_cme))
      end

      xit 'should report OK for registered_params_with_custom_date' do
        post :create, enrollment: registered_params_with_custom_date
        expect_create_success_with_model('enrollment', course_special_link(course_1.first_active_cme))
      end

      xit 'should report OK for non_registered_params' do
        post :create, enrollment: non_registered_params
        expect_create_success_with_model('enrollment', course_special_link(course_1.first_active_cme))
      end

    end

    describe "PUT 'update/1'" do
      xit 'should redirect to sign_in' do
        put :update, id: 1, params: registered_params
        expect_bounce_as_not_signed_in
      end


      xit 'should redirect to sign_in' do
        put :update, id: 1, params: registered_params_with_custom_date
        expect_bounce_as_not_signed_in
      end
    end

    describe "PUT 'create_with_order'" do
      xit 'should redirect to sign_in' do
        get :create_with_order
        expect_bounce_as_not_signed_in
      end
    end

    describe "PUT 'basic_create'" do
      xit 'should report OK for no_exam_body_params' do
        get :basic_create, enrollment: no_exam_body_params
        expect_bounce_as_not_signed_in
      end
    end

    describe "PUT 'pause'" do
      xit 'should redirect to sign_in' do
        post :pause, enrollment_id: enrollment_1.id
        expect_bounce_as_not_signed_in
      end
    end

    describe "PUT 'activate'" do
      xit 'should redirect to sign_in' do
        post :activate, enrollment_id: enrollment_2.id
        expect_bounce_as_not_signed_in
      end
    end

  end

  context 'Logged in as a admin_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(admin_user)
    end

    describe "GET 'edit/1'" do
      it 'should respond OK with enrollment_1' do
        get :edit, id: enrollment_1.id
        expect_edit_success_with_model('enrollment', enrollment_1.id)
      end
    end

    describe "POST 'create'" do
      xit 'should report OK for registered_params' do
        post :create, params: registered_params
        expect_create_success_with_model('enrollment', course_special_link(course_1.first_active_cme))
      end

      xit 'should report OK for registered_params_with_custom_date' do
        post :create, enrollment: registered_params_with_custom_date
        expect_create_success_with_model('enrollment', course_special_link(course_1.first_active_cme))
      end

      xit 'should report OK for non_registered_params' do
        post :create, enrollment: non_registered_params
        expect_create_success_with_model('enrollment', course_special_link(course_1.first_active_cme))
      end

    end

    describe "PUT 'update/1'" do
      xit 'should redirect to sign_in' do
        put :update, id: 1, params: registered_params
        expect_bounce_as_not_signed_in
      end


      xit 'should redirect to sign_in' do
        put :update, id: 1, params: registered_params_with_custom_date
        expect_bounce_as_not_signed_in
      end
    end

    describe "PUT 'create_with_order'" do
      xit 'should redirect to sign_in' do
        get :create_with_order
        expect_bounce_as_not_signed_in
      end
    end

    describe "PUT 'basic_create'" do
      xit 'should report OK for no_exam_body_params' do
        get :basic_create, enrollment: no_exam_body_params
        expect_bounce_as_not_signed_in
      end
    end

    describe "PUT 'pause'" do
      xit 'should redirect to sign_in' do
        post :pause, enrollment_id: enrollment_1.id
        expect_bounce_as_not_signed_in
      end
    end

    describe "PUT 'activate'" do
      xit 'should redirect to sign_in' do
        post :activate, enrollment_id: enrollment_2.id
        expect_bounce_as_not_signed_in
      end
    end

  end
end
