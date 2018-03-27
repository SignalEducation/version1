require 'rails_helper'
require 'support/system_setup'
require 'support/users_and_groups_setup'
require 'support/course_content'

RSpec.describe EnrollmentManagementController, :type => :controller do

  include_context 'system_setup'
  include_context 'users_and_groups_setup'
  include_context 'course_content'

  let!(:enrollment_1) { FactoryBot.create(:enrollment,
                                          subject_course_id: subject_course_1.id) }
  let!(:valid_params) { FactoryBot.attributes_for(:enrollment,
                                                  exam_date: '2018-08-18') }

  context 'Not logged in: ' do

    describe 'GET edit' do
      it 'should redirect to sign_in' do
        get :edit, id: enrollment_1.id
        expect_bounce_as_not_signed_in
      end
    end

    describe 'PUT update' do
      it 'should redirect to sign_in' do
        put :update, id: enrollment_1.id, enrollment: valid_params
        expect_bounce_as_not_signed_in
      end
    end

    describe 'GET show' do
      it 'should redirect to sign_in' do
        get :show, id: enrollment_1.id
        expect_bounce_as_not_signed_in
      end
    end

    describe 'POST create_new_scul' do
      it 'should redirect to sign_in' do
        post :create_new_scul, id: enrollment_1.id
        expect_bounce_as_not_signed_in
      end
    end

  end

  context 'Logged in as a valid_trial student_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(valid_trial_student)
    end

    describe 'GET edit' do
      it 'should redirect to sign_in' do
        get :edit, id: enrollment_1.id
        expect_bounce_as_not_allowed
      end
    end

    describe 'PUT update' do
      it 'should redirect to sign_in' do
        put :update, id: enrollment_1.id, enrollment: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe 'GET show' do
      it 'should redirect to sign_in' do
        get :show, id: enrollment_1.id
        expect_bounce_as_not_allowed
      end
    end

    describe 'POST create_new_scul' do
      it 'should redirect to sign_in' do
        post :create_new_scul, id: enrollment_1.id
        expect_bounce_as_not_allowed
      end
    end

  end

  context 'Logged in as a invalid_trial_student: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(invalid_trial_student)
    end

    describe 'GET edit' do
      it 'should redirect to sign_in' do
        get :edit, id: enrollment_1.id
        expect_bounce_as_not_allowed
      end
    end

    describe 'PUT update' do
      it 'should redirect to sign_in' do
        put :update, id: enrollment_1.id, enrollment: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe 'GET show' do
      it 'should redirect to sign_in' do
        get :show, id: enrollment_1.id
        expect_bounce_as_not_allowed
      end
    end

    describe 'POST create_new_scul' do
      it 'should redirect to sign_in' do
        post :create_new_scul, id: enrollment_1.id
        expect_bounce_as_not_allowed
      end
    end

  end

  context 'Logged in as a valid_subscription_student: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(valid_subscription_student)
    end

    describe 'GET edit' do
      it 'should redirect to sign_in' do
        get :edit, id: enrollment_1.id
        expect_bounce_as_not_allowed
      end
    end

    describe 'PUT update' do
      it 'should redirect to sign_in' do
        put :update, id: enrollment_1.id, enrollment: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe 'GET show' do
      it 'should redirect to sign_in' do
        get :show, id: enrollment_1.id
        expect_bounce_as_not_allowed
      end
    end

    describe 'POST create_new_scul' do
      it 'should redirect to sign_in' do
        post :create_new_scul, id: enrollment_1.id
        expect_bounce_as_not_allowed
      end
    end

  end

  context 'Logged in as a invalid_subscription_student: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(invalid_subscription_student)
    end

    describe 'GET edit' do
      it 'should redirect to sign_in' do
        get :edit, id: enrollment_1.id
        expect_bounce_as_not_allowed
      end
    end

    describe 'PUT update' do
      it 'should redirect to sign_in' do
        put :update, id: enrollment_1.id, enrollment: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe 'GET show' do
      it 'should redirect to sign_in' do
        get :show, id: enrollment_1.id
        expect_bounce_as_not_allowed
      end
    end

    describe 'POST create_new_scul' do
      it 'should redirect to sign_in' do
        post :create_new_scul, id: enrollment_1.id
        expect_bounce_as_not_allowed
      end
    end

  end

  context 'Logged in as a comp_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(comp_user)
    end

    describe 'GET edit' do
      it 'should redirect to sign_in' do
        get :edit, id: enrollment_1.id
        expect_bounce_as_not_allowed
      end
    end

    describe 'PUT update' do
      it 'should redirect to sign_in' do
        put :update, id: enrollment_1.id, enrollment: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe 'GET show' do
      it 'should redirect to sign_in' do
        get :show, id: enrollment_1.id
        expect_bounce_as_not_allowed
      end
    end

    describe 'POST create_new_scul' do
      it 'should redirect to sign_in' do
        post :create_new_scul, id: enrollment_1.id
        expect_bounce_as_not_allowed
      end
    end

  end

  context 'Logged in as a tutor_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(tutor_user)
    end

    describe 'GET edit' do
      it 'should redirect to sign_in' do
        get :edit, id: enrollment_1.id
        expect_bounce_as_not_allowed
      end
    end

    describe 'PUT update' do
      it 'should redirect to sign_in' do
        put :update, id: enrollment_1.id, enrollment: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe 'GET show' do
      it 'should redirect to sign_in' do
        get :show, id: enrollment_1.id
        expect_bounce_as_not_allowed
      end
    end

    describe 'POST create_new_scul' do
      it 'should redirect to sign_in' do
        post :create_new_scul, id: enrollment_1.id
        expect_bounce_as_not_allowed
      end
    end

  end

  context 'Logged in as a content_manager_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(content_manager_user)
    end

    describe 'GET edit' do
      it 'should redirect to sign_in' do
        get :edit, id: enrollment_1.id
        expect_bounce_as_not_allowed
      end
    end

    describe 'PUT update' do
      it 'should redirect to sign_in' do
        put :update, id: enrollment_1.id, enrollment: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe 'GET show' do
      it 'should redirect to sign_in' do
        get :show, id: enrollment_1.id
        expect_bounce_as_not_allowed
      end
    end

    describe 'POST create_new_scul' do
      it 'should redirect to sign_in' do
        post :create_new_scul, id: enrollment_1.id
        expect_bounce_as_not_allowed
      end
    end

  end

  context 'Logged in as a customer_support_manager_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(customer_support_manager_user)
    end

    describe 'GET edit' do
      it 'should respond OK with enrollment_1' do
        get :edit, id: enrollment_1.id
        expect_edit_success_with_model('enrollment', enrollment_1.id)
      end
    end

    describe 'PUT update' do
      it 'should respond OK to valid params for enrollment_1' do
        put :update, id: enrollment_1.id, enrollment: valid_params
        expect(flash[:error]).to be_nil
        expect(flash[:success]).to eq(I18n.t('controllers.enrollments.admin_update.flash.success'))
        expect(response.status).to eq(302)
        expect(response).to redirect_to(enrollment_management_url(enrollment_1))
      end
    end

    describe 'GET show' do
      it 'should see enrollment_1' do
        get :show, id: enrollment_1.id
        expect_show_success_with_model('enrollment', enrollment_1.id)
      end
    end

    describe 'POST create_new_scul' do
      it 'should respond OK to enrollment_1 id' do
        post :create_new_scul, id: enrollment_1.id
        expect(flash[:success]).to eq(I18n.t('controllers.enrollments.admin_create_new_scul.flash.success'))
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(302)
        expect(response).to redirect_to(enrollment_management_url(enrollment_1))

      end
    end

  end

  context 'Logged in as a marketing_manager_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(marketing_manager_user)
    end

    describe 'GET edit' do
      it 'should redirect to sign_in' do
        get :edit, id: enrollment_1.id
        expect_bounce_as_not_allowed
      end
    end

    describe 'PUT update' do
      it 'should redirect to sign_in' do
        put :update, id: enrollment_1.id, enrollment: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe 'GET show' do
      it 'should redirect to sign_in' do
        get :show, id: enrollment_1.id
        expect_bounce_as_not_allowed
      end
    end

    describe 'POST create_new_scul' do
      it 'should redirect to sign_in' do
        post :create_new_scul, id: enrollment_1.id
        expect_bounce_as_not_allowed
      end
    end

  end

  context 'Logged in as a admin_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(admin_user)
    end

    describe 'GET edit' do
      it 'should respond OK with enrollment_1' do
        get :edit, id: enrollment_1.id
        expect_edit_success_with_model('enrollment', enrollment_1.id)
      end
    end

    describe 'PUT update' do
      it 'should respond OK to valid params for enrollment_1' do
        put :update, id: enrollment_1.id, enrollment: valid_params
        expect(flash[:error]).to be_nil
        expect(flash[:success]).to eq(I18n.t('controllers.enrollments.admin_update.flash.success'))
        expect(response.status).to eq(302)
        expect(response).to redirect_to(enrollment_management_url(enrollment_1))
      end
    end

    describe 'GET show' do
      it 'should see enrollment_1' do
        get :show, id: enrollment_1.id
        expect_show_success_with_model('enrollment', enrollment_1.id)
      end
    end

    describe 'POST create_new_scul' do
      it 'should respond OK to enrollment_1 id' do
        post :create_new_scul, id: enrollment_1.id
        expect(flash[:success]).to eq(I18n.t('controllers.enrollments.admin_create_new_scul.flash.success'))
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(302)
        expect(response).to redirect_to(enrollment_management_url(enrollment_1))

      end
    end

  end


end