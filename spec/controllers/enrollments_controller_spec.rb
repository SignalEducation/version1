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
require 'support/course_content'

RSpec.describe EnrollmentsController, type: :controller do

  include_context 'users_and_groups_setup'
  include_context 'course_content'

  let!(:exam_sitting_1) { FactoryGirl.create(:exam_sitting, subject_course_id: subject_course_1.id, exam_body_id: exam_body_1.id) }
  let!(:exam_sitting_2) { FactoryGirl.create(:exam_sitting, subject_course_id: subject_course_1.id, exam_body_id: exam_body_1.id) }

  let!(:enrollment_1) { FactoryGirl.create(:enrollment, user_id: student_user.id, subject_course_id: subject_course_1.id, exam_body_id: exam_body_1.id) }
  let!(:enrollment_2) { FactoryGirl.create(:enrollment, user_id: student_user.id, subject_course_id: subject_course_1.id, exam_body_id: exam_body_1.id) }

  let!(:valid_params) { {enrollment: {subject_course_id: subject_course_1.id}, exam_date: exam_sitting_1.date, custom_exam_date: ''} }
  let!(:invalid_params) { {enrollment: {subject_course_id: nil}, exam_date: exam_sitting_1.date, custom_exam_date: ''} }
  let!(:custom_date_params) { {enrollment: {subject_course_id: subject_course_1.id}, exam_date: '', custom_exam_date: '2016-12-01'} }



  context 'Not logged in: ' do

    describe "GET 'edit'" do
      it 'should redirect to sign_in' do
        get :edit, id: 1
        expect_bounce_as_not_signed_in
      end
    end

    describe "POST 'create'" do
      it 'should redirect to sign_in' do
        post :create, enrollment: valid_params
        expect_bounce_as_not_signed_in
      end
    end

    describe "PUT 'update'" do
      it 'should redirect to sign_in' do
        put :update, id: 1, enrollment: valid_params
        expect_bounce_as_not_signed_in
      end
    end

    describe "GET 'basic_create'" do
      it 'should redirect to sign_in' do
        get :basic_create, subject_course_name_url: subject_course_1.name_url
        expect_bounce_as_not_signed_in
      end
    end

    describe "GET 'admin_create_new_scul'" do
      it 'should redirect to sign_in' do
        get :admin_create_new_scul, id: enrollment_1.id
        expect_bounce_as_not_signed_in
      end
    end

    describe "GET 'admin_edit'" do
      it 'should redirect to sign_in' do
        get :admin_edit, id: enrollment_2.id
        expect_bounce_as_not_signed_in
      end
    end

    describe "PUT 'admin_update'" do
      it 'should redirect to sign_in' do
        post :admin_update, id: enrollment_2.id
        expect_bounce_as_not_signed_in
      end
    end

    describe "GET 'admin_show'" do
      it 'should redirect to sign_in' do
        get :admin_show, id: enrollment_2.id
        expect_bounce_as_not_signed_in
      end
    end

  end

  context 'Logged in as a student_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(student_user)
    end

    describe "GET 'edit/1'" do
      it 'should respond OK with enrollment_1' do
        get :edit, id: enrollment_1.id
        expect_edit_success_with_model('enrollment', enrollment_1.id)
      end
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

      xit 'should report OK for attaching previous enrollment scul_id' do
        post :create, scul_id_params
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

    describe "PUT 'update/1'" do
      it 'should respond OK with new params' do
        put :update, id: enrollment_1.id, enrollment: {notifications: false}
        expect(flash[:error]).to be_nil
        expect(flash[:success]).to eq(I18n.t('controllers.enrollments.update.flash.success'))
        expect(response.status).to eq(302)
        expect(response).to redirect_to(account_url(anchor: :enrollments))
      end
    end

    describe "GET 'basic_create'" do
      it 'should respond OK' do
        get :basic_create, subject_course_name_url: subject_course_1.name_url
        #This should fail as only non-student users can do this
        expect_create_success_with_model('enrollment', course_url(subject_course_1.name_url, subject_course_1.first_active_cme.course_module.name_url, subject_course_1.first_active_cme.name_url))
      end
    end

    describe "GET 'admin_create_new_scul'" do
      it 'should bounce as not allowed' do
        get :admin_create_new_scul, id: enrollment_1.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'admin_edit'" do
      it 'should bounce as not allowed' do
        get :admin_edit, id: enrollment_1.id
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'admin_update'" do
      it 'should bounce as not allowed' do
        post :admin_update, id: enrollment_2.id, enrollment: {active: true, expired: false, notifications: false}
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'admin_show'" do
      it 'should bounce as not allowed' do
        get :admin_show, id: enrollment_2.id
        expect_bounce_as_not_allowed
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
      it 'should report OK for valid_params' do
        post :create, valid_params
        expect_create_success_with_model('enrollment', library_course_url(subject_course_1.parent.name_url, subject_course_1.name_url))
      end

      it 'should report OK for params_with_custom_date' do
        post :create, custom_date_params
        expect_create_success_with_model('enrollment', library_course_url(subject_course_1.parent.name_url, subject_course_1.name_url))
      end

      xit 'should report OK for attaching previous enrollment scul_id' do
        post :create, scul_id_params
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

    describe "PUT 'update/1'" do
      it 'should respond OK with new params' do
        put :update, id: enrollment_1.id, enrollment: {notifications: false}
        expect(flash[:error]).to be_nil
        expect(flash[:success]).to eq(I18n.t('controllers.enrollments.update.flash.success'))
        expect(response.status).to eq(302)
        expect(response).to redirect_to(account_url(anchor: :enrollments))
      end
    end

    describe "GET 'basic_create'" do
      it 'should respond OK' do
        get :basic_create, subject_course_name_url: subject_course_1.name_url
        expect_create_success_with_model('enrollment', course_url(subject_course_1.name_url, subject_course_1.first_active_cme.course_module.name_url, subject_course_1.first_active_cme.name_url))
      end
    end

    describe "GET 'admin_create_new_scul'" do
      it 'should bounce as not allowed' do
        get :admin_create_new_scul, id: enrollment_1.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'admin_edit'" do
      it 'should bounce as not allowed' do
        get :admin_edit, id: enrollment_1.id
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'admin_update'" do
      it 'should bounce as not allowed' do
        post :admin_update, id: enrollment_2.id, enrollment: {active: true, expired: false, notifications: false}
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'admin_show'" do
      it 'should bounce as not allowed' do
        get :admin_show, id: enrollment_2.id
        expect_bounce_as_not_allowed
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
      it 'should report OK for valid_params' do
        post :create, valid_params
        expect_create_success_with_model('enrollment', library_course_url(subject_course_1.parent.name_url, subject_course_1.name_url))
      end

      it 'should report OK for params_with_custom_date' do
        post :create, custom_date_params
        expect_create_success_with_model('enrollment', library_course_url(subject_course_1.parent.name_url, subject_course_1.name_url))
      end

      xit 'should report OK for attaching previous enrollment scul_id' do
        post :create, scul_id_params
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

    describe "PUT 'update/1'" do
      it 'should respond OK with new params' do
        put :update, id: enrollment_1.id, enrollment: {notifications: false}
        expect(flash[:error]).to be_nil
        expect(flash[:success]).to eq(I18n.t('controllers.enrollments.update.flash.success'))
        expect(response.status).to eq(302)
        expect(response).to redirect_to(account_url(anchor: :enrollments))
      end
    end

    describe "GET 'basic_create'" do
      it 'should respond OK' do
        get :basic_create, subject_course_name_url: subject_course_1.name_url
        expect_create_success_with_model('enrollment', course_url(subject_course_1.name_url, subject_course_1.first_active_cme.course_module.name_url, subject_course_1.first_active_cme.name_url))
      end
    end

    describe "GET 'admin_create_new_scul'" do
      it 'should bounce as not allowed' do
        get :admin_create_new_scul, id: enrollment_1.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'admin_edit'" do
      it 'should bounce as not allowed' do
        get :admin_edit, id: enrollment_1.id
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'admin_update'" do
      it 'should bounce as not allowed' do
        post :admin_update, id: enrollment_2.id, enrollment: {active: true, expired: false, notifications: false}
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'admin_show'" do
      it 'should bounce as not allowed' do
        get :admin_show, id: enrollment_2.id
        expect_bounce_as_not_allowed
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
      it 'should report OK for valid_params' do
        post :create, valid_params
        expect_create_success_with_model('enrollment', library_course_url(subject_course_1.parent.name_url, subject_course_1.name_url))
      end

      it 'should report OK for params_with_custom_date' do
        post :create, custom_date_params
        expect_create_success_with_model('enrollment', library_course_url(subject_course_1.parent.name_url, subject_course_1.name_url))
      end

      xit 'should report OK for attaching previous enrollment scul_id' do
        post :create, scul_id_params
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

    describe "PUT 'update/1'" do
      it 'should respond OK with new params' do
        put :update, id: enrollment_1.id, enrollment: {notifications: false}
        expect(flash[:error]).to be_nil
        expect(flash[:success]).to eq(I18n.t('controllers.enrollments.update.flash.success'))
        expect(response.status).to eq(302)
        expect(response).to redirect_to(account_url(anchor: :enrollments))
      end
    end

    describe "GET 'basic_create'" do
      it 'should respond OK' do
        get :basic_create, subject_course_name_url: subject_course_1.name_url
        expect_create_success_with_model('enrollment', course_url(subject_course_1.name_url, subject_course_1.first_active_cme.course_module.name_url, subject_course_1.first_active_cme.name_url))
      end
    end

    describe "GET 'admin_create_new_scul'" do
      it 'should bounce as not allowed' do
        get :admin_create_new_scul, id: enrollment_1.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'admin_edit'" do
      it 'should bounce as not allowed' do
        get :admin_edit, id: enrollment_1.id
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'admin_update'" do
      it 'should bounce as not allowed' do
        post :admin_update, id: enrollment_2.id, enrollment: {active: true, expired: false, notifications: false}
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'admin_show'" do
      it 'should bounce as not allowed' do
        get :admin_show, id: enrollment_2.id
        expect_bounce_as_not_allowed
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
      it 'should report OK for valid_params' do
        post :create, valid_params
        expect_create_success_with_model('enrollment', library_course_url(subject_course_1.parent.name_url, subject_course_1.name_url))
      end

      it 'should report OK for params_with_custom_date' do
        post :create, custom_date_params
        expect_create_success_with_model('enrollment', library_course_url(subject_course_1.parent.name_url, subject_course_1.name_url))
      end

      xit 'should report OK for attaching previous enrollment scul_id' do
        post :create, scul_id_params
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

    describe "PUT 'update/1'" do
      it 'should respond OK with new params' do
        put :update, id: enrollment_1.id, enrollment: {notifications: false}
        expect(flash[:error]).to be_nil
        expect(flash[:success]).to eq(I18n.t('controllers.enrollments.update.flash.success'))
        expect(response.status).to eq(302)
        expect(response).to redirect_to(account_url(anchor: :enrollments))
      end
    end

    describe "GET 'basic_create'" do
      it 'should respond OK' do
        get :basic_create, subject_course_name_url: subject_course_1.name_url
        expect_create_success_with_model('enrollment', course_url(subject_course_1.name_url, subject_course_1.first_active_cme.course_module.name_url, subject_course_1.first_active_cme.name_url))
      end
    end

    describe "GET 'admin_create_new_scul'" do
      it 'should bounce as not allowed' do
        get :admin_create_new_scul, id: enrollment_1.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'admin_edit'" do
      it 'should bounce as not allowed' do
        get :admin_edit, id: enrollment_1.id
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'admin_update'" do
      it 'should bounce as not allowed' do
        post :admin_update, id: enrollment_2.id, enrollment: {active: true, expired: false, notifications: false}
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'admin_show'" do
      it 'should bounce as not allowed' do
        get :admin_show, id: enrollment_2.id
        expect_bounce_as_not_allowed
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
      it 'should report OK for valid_params' do
        post :create, valid_params
        expect_create_success_with_model('enrollment', library_course_url(subject_course_1.parent.name_url, subject_course_1.name_url))
      end

      it 'should report OK for params_with_custom_date' do
        post :create, custom_date_params
        expect_create_success_with_model('enrollment', library_course_url(subject_course_1.parent.name_url, subject_course_1.name_url))
      end

      xit 'should report OK for attaching previous enrollment scul_id' do
        post :create, scul_id_params
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

    describe "PUT 'update/1'" do
      it 'should respond OK with new params' do
        put :update, id: enrollment_1.id, enrollment: {notifications: false}
        expect(flash[:error]).to be_nil
        expect(flash[:success]).to eq(I18n.t('controllers.enrollments.update.flash.success'))
        expect(response.status).to eq(302)
        expect(response).to redirect_to(account_url(anchor: :enrollments))
      end
    end

    describe "GET 'basic_create'" do
      it 'should respond OK' do
        get :basic_create, subject_course_name_url: subject_course_1.name_url
        expect_create_success_with_model('enrollment', course_url(subject_course_1.name_url, subject_course_1.first_active_cme.course_module.name_url, subject_course_1.first_active_cme.name_url))
      end
    end

    describe "GET 'admin_create_new_scul'" do
      it 'should bounce as not allowed' do
        get :admin_create_new_scul, id: enrollment_1.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'admin_edit'" do
      it 'should bounce as not allowed' do
        get :admin_edit, id: enrollment_1.id
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'admin_update'" do
      it 'should bounce as not allowed' do
        post :admin_update, id: enrollment_2.id, enrollment: {active: true, expired: false, notifications: false}
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'admin_show'" do
      it 'should bounce as not allowed' do
        get :admin_show, id: enrollment_2.id
        expect_bounce_as_not_allowed
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
      it 'should report OK for valid_params' do
        post :create, valid_params
        expect_create_success_with_model('enrollment', library_course_url(subject_course_1.parent.name_url, subject_course_1.name_url))
      end

      it 'should report OK for params_with_custom_date' do
        post :create, custom_date_params
        expect_create_success_with_model('enrollment', library_course_url(subject_course_1.parent.name_url, subject_course_1.name_url))
      end

      xit 'should report OK for attaching previous enrollment scul_id' do
        post :create, scul_id_params
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

    describe "PUT 'update/1'" do
      it 'should respond OK with new params' do
        put :update, id: enrollment_1.id, enrollment: {notifications: false}
        expect(flash[:error]).to be_nil
        expect(flash[:success]).to eq(I18n.t('controllers.enrollments.update.flash.success'))
        expect(response.status).to eq(302)
        expect(response).to redirect_to(account_url(anchor: :enrollments))
      end
    end

    describe "GET 'basic_create'" do
      it 'should respond OK' do
        get :basic_create, subject_course_name_url: subject_course_1.name_url
        expect_create_success_with_model('enrollment', course_url(subject_course_1.name_url, subject_course_1.first_active_cme.course_module.name_url, subject_course_1.first_active_cme.name_url))
      end
    end

    describe "GET 'admin_create_new_scul'" do
      it 'should respond OK' do
        get :admin_create_new_scul, id: enrollment_1.id
        expect(flash[:error]).to be_nil
        expect(flash[:success]).to eq(I18n.t('controllers.enrollments.admin_create_new_scul.flash.success'))
        expect(response.status).to eq(302)
        expect(response).to redirect_to(user_enrollments_details_url(enrollment_1.user))

      end
    end

    describe "GET 'admin_edit'" do
      it 'should respond OK' do
        get :admin_edit, id: enrollment_1.id
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:admin_edit)

      end
    end

    describe "PUT 'admin_update'" do
      it 'should respond OK' do
        post :admin_update, id: enrollment_2.id, enrollment: {active: true, expired: false, notifications: false}
        expect(flash[:error]).to be_nil
        expect(flash[:success]).to eq(I18n.t('controllers.enrollments.admin_update.flash.success'))
        expect(response.status).to eq(302)
        expect(response).to redirect_to(user_enrollments_details_url(enrollment_1.user))
      end
    end

    describe "GET 'admin_show'" do
      it 'should respond OK' do
        get :admin_show, id: enrollment_2.id
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:admin_show)
      end
    end

  end
end
