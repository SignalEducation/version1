require 'rails_helper'
require 'authlogic/test_case'

RSpec.describe UserVerificationsController, :type => :controller do

  let!(:gbp) { FactoryBot.create(:gbp) }
  let!(:uk) { FactoryBot.create(:uk, currency_id: gbp.id, name: 'United Kingdom') }
  let!(:student_user_group ) { FactoryBot.create(:student_user_group ) }
  let!(:verified_student_user) { FactoryBot.create(:verified_user, user_group_id: student_user_group.id) }
  let!(:unverified_student_user) { FactoryBot.create(:unverified_user, user_group_id: student_user_group.id) }
  let!(:password_change_student_user) { FactoryBot.create(:password_change_user, user_group_id: student_user_group.id) }
  let!(:exam_body_1) { FactoryBot.create(:exam_body) }
  let!(:exam_body_2) { FactoryBot.create(:exam_body, name: 'CPD') }
  let!(:group_1) { FactoryBot.create(:group, exam_body_id: exam_body_2.id, name: 'CPD') }
  let!(:course_1) { FactoryBot.create(:active_course, group_id: group_1.id, exam_body_id: exam_body_1.id) }

  context 'Non-verified user' do
    before :each do
      allow_any_instance_of(HubSpot::Contacts).to receive(:batch_create).and_return(:ok)
    end

    describe "Get 'update'" do
      it 'returns success when given a valid code' do
        get :update, params: { email_verification_code: unverified_student_user.email_verification_code }
        expect(controller.params[:email_verification_code]).to eq(unverified_student_user.email_verification_code)
        expect(response.status).to eq(302)
        expect(response).to redirect_to(student_dashboard_path)
        expect(flash[:error]).to be_nil
      end

      it 'returns redirects to set_password' do
        get :update, params: { email_verification_code: password_change_student_user.email_verification_code }
        expect(controller.params[:email_verification_code]).to eq(password_change_student_user.email_verification_code)
        expect(response.status).to eq(302)
        password_change_student_user.reload
        expect(response).to redirect_to(set_password_url(id: password_change_student_user.password_reset_token))
        expect(flash[:error]).to be_nil
      end

      it 'returns redirects to cpd onboarding' do
        unverified_student_user.update_attribute(:preferred_exam_body_id, exam_body_2.id)
        unverified_student_user.reload
        get :update, params: { email_verification_code: unverified_student_user.email_verification_code }
        expect(controller.params[:email_verification_code]).to eq(unverified_student_user.email_verification_code)
        expect(response.status).to eq(302)

        expect(response).to redirect_to(registration_onboarding_url(exam_body_2.group.name_url))
        expect(flash[:error]).to be_nil
      end

      it 'returns error when given an invalid code' do
        get :update, params: { email_verification_code: 'XYZ123' }
        expect(response.status).to eq(302)
        expect(flash[:success]).to be_nil
        expect(flash[:warning]).to eq('Sorry! That link has expired. Please try to sign in or contact us for assistance')
      end
    end

    describe "Get 'account_verified'" do
      before(:each) do
        activate_authlogic
        UserSession.create!(unverified_student_user)
      end

      it 'returns success when given a valid code' do
        get :account_verified, params: { group_url: group_1.name_url }
        expect(response.status).to eq(200)
        expect(response).to render_template(:account_verified)
        expect(flash[:error]).to be_nil
      end
    end

    describe "Post 'resend_verification_mail'" do
      it 'returns success when given a valid code' do
        request.env['HTTP_REFERER'] = 'http://test.host/account_verified'
        post :resend_verification_mail, params: { email_verification_code: unverified_student_user.email_verification_code }
        expect(response.status).to eq(302)
        expect(response).to redirect_to(request.referrer)
        expect(flash[:error]).to be_nil
      end

      it 'returns error flash message' do
        request.env['HTTP_REFERER'] = 'http://test.host/account_verified'
        post :resend_verification_mail, params: { email_verification_code: verified_student_user.email_verification_code }
        expect(response.status).to eq(302)
        expect(response).to redirect_to(request.referrer)
        expect(flash[:error]).to eq('Verification Email was not sent.')
      end
    end
  end
end
